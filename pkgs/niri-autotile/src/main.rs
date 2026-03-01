use anyhow::{Context, Result};
use log::{debug, error, info, warn};
use niri_ipc::socket::Socket;
use niri_ipc::{Action, Event, Request, Response, SizeChange, Window};
use std::collections::HashMap;

const MAXIMIZED_RATIO_THRESHOLD: f64 = 0.9;
const HALF_PROPORTION: f64 = 0.5;
const PROPORTION_TOLERANCE: f64 = 0.05;

struct NiriState {
    windows: Vec<Window>,
    output_widths: HashMap<String, f64>,
    ws_outputs: HashMap<u64, String>,
}

#[derive(Debug, PartialEq, Eq, Clone, Copy)]
struct WindowPosition {
    workspace_id: u64,
    column: usize,
    tile: usize,
}

struct NiriContext {
    request_socket: Socket,
    tracked_window_positions: HashMap<u64, WindowPosition>,
}

impl NiriContext {
    fn new() -> Result<Self> {
        let request_socket = Socket::connect().context("connecting to niri for requests")?;
        Ok(Self {
            request_socket,
            tracked_window_positions: HashMap::new(),
        })
    }

    fn send_action(&mut self, action: Action) -> Result<()> {
        let reply = self
            .request_socket
            .send(Request::Action(action.clone()))
            .context("sending action to niri")?;
        match reply {
            Ok(Response::Handled) => Ok(()),
            Ok(other) => {
                warn!(
                    "unexpected response from niri for action {:?}: {:?}",
                    action, other
                );
                Ok(())
            }
            Err(msg) => {
                error!("niri returned error for action {:?}: {}", action, msg);
                Ok(())
            }
        }
    }

    fn query_focused_window(&mut self) -> Result<Option<u64>> {
        let reply = self
            .request_socket
            .send(Request::FocusedWindow)
            .context("querying focused window")?;
        match reply {
            Ok(Response::FocusedWindow(Some(w))) => Ok(Some(w.id)),
            Ok(Response::FocusedWindow(None)) => Ok(None),
            _ => {
                warn!("unexpected response when querying focused window");
                Ok(None)
            }
        }
    }

    fn query_full_state(&mut self) -> Result<NiriState> {
        let windows = match self
            .request_socket
            .send(Request::Windows)
            .context("querying windows")?
        {
            Ok(Response::Windows(w)) => w,
            _ => anyhow::bail!("failed to query windows"),
        };

        let output_widths = match self
            .request_socket
            .send(Request::Outputs)
            .context("querying outputs")?
        {
            Ok(Response::Outputs(outputs)) => {
                let mut widths = HashMap::new();
                for (name, out) in outputs {
                    if let Some(logical) = out.logical {
                        if logical.width > 0 {
                            widths.insert(name, logical.width as f64);
                        }
                    }
                }
                widths
            }
            _ => anyhow::bail!("failed to query outputs"),
        };

        let ws_outputs = match self
            .request_socket
            .send(Request::Workspaces)
            .context("querying workspaces")?
        {
            Ok(Response::Workspaces(workspaces)) => {
                let mut mapping = HashMap::new();
                for ws in workspaces {
                    if let Some(output) = ws.output {
                        mapping.insert(ws.id, output);
                    }
                }
                mapping
            }
            _ => anyhow::bail!("failed to query workspaces"),
        };

        Ok(NiriState {
            windows,
            output_widths,
            ws_outputs,
        })
    }

    fn window_proportion(&self, window_id: u64, state: &NiriState, windows_map: &HashMap<u64, &Window>) -> Option<f64> {
        let w = windows_map.get(&window_id)?;
        let ws_id = w.workspace_id?;
        let output_name = state.ws_outputs.get(&ws_id)?;
        let &output_width = state.output_widths.get(output_name)?;
        if output_width <= 0.0 {
            return None;
        }
        Some(w.layout.tile_size.0 / output_width)
    }

    fn is_maximized(&self, window_id: u64, state: &NiriState, windows_map: &HashMap<u64, &Window>) -> bool {
        self.window_proportion(window_id, state, windows_map)
            .map(|r| {
                debug!("window {} proportion={:.2}", window_id, r);
                r > MAXIMIZED_RATIO_THRESHOLD
            })
            .unwrap_or(false)
    }

    fn is_at_proportion(&self, window_id: u64, target: f64, state: &NiriState, windows_map: &HashMap<u64, &Window>) -> bool {
        self.window_proportion(window_id, state, windows_map)
            .map(|r| (r - target).abs() < PROPORTION_TOLERANCE)
            .unwrap_or(false)
    }

    fn perform_maximize_action(&mut self, target_window_id: u64) -> Result<()> {
        let original_focus = self.query_focused_window().ok().flatten();
        if original_focus != Some(target_window_id) {
            self.send_action(Action::FocusWindow { id: target_window_id })?;
        }
        self.send_action(Action::MaximizeColumn {})?;
        if let Some(orig_id) = original_focus {
            if orig_id != target_window_id {
                let _ = self.send_action(Action::FocusWindow { id: orig_id });
            }
        }
        Ok(())
    }

    fn evaluate_workspace(
        &mut self,
        ws_id: u64,
        state: &NiriState,
        windows_map: &HashMap<u64, &Window>,
    ) -> Result<()> {
        let tiled_windows: Vec<&Window> = state
            .windows
            .iter()
            .filter(|w| w.workspace_id == Some(ws_id) && !w.is_floating)
            .collect();

        if tiled_windows.is_empty() {
            return Ok(());
        }

        let mut unique_columns = std::collections::HashSet::new();
        for w in &tiled_windows {
            if let Some((col_idx, _)) = w.layout.pos_in_scrolling_layout {
                unique_columns.insert(col_idx);
            }
        }

        let column_count = unique_columns.len();

        match column_count {
            0 => {}
            1 => {
                let win_id = tiled_windows[0].id;
                if !self.is_maximized(win_id, state, windows_map) {
                    info!("workspace {}: single column -> maximizing window {}", ws_id, win_id);
                    self.perform_maximize_action(win_id)?;
                }
            }
            2 => {
                let mut cols_vec: Vec<usize> = unique_columns.into_iter().collect();
                cols_vec.sort_unstable();

                // Skip if both columns are already at ~50%
                let already_correct = cols_vec.iter().all(|&col_idx| {
                    tiled_windows
                        .iter()
                        .find(|w| w.layout.pos_in_scrolling_layout.map(|(c, _)| c) == Some(col_idx))
                        .map(|w| self.is_at_proportion(w.id, HALF_PROPORTION, state, windows_map))
                        .unwrap_or(false)
                });

                if already_correct {
                    debug!("workspace {}: two columns already at 50%, skipping", ws_id);
                    return Ok(());
                }

                info!("workspace {}: two columns -> resizing both to 50%", ws_id);

                // Resize right column first, then left. When we focus the left
                // column (100% wide, starting at x=0), niri is forced to scroll
                // the viewport to x=0 — it's the only valid position to fully
                // show a full-width column at x=0. After resizing left to 50%,
                // both columns fit within the screen width (~952px each + gaps).
                // FocusColumnRight then lands on the right column with no scroll
                // needed (it's already visible), ending with focus on the new
                // window and both windows on screen.
                for &col_idx in cols_vec.iter().rev() {
                    if let Some(w) = tiled_windows.iter().find(|w| {
                        w.layout.pos_in_scrolling_layout.map(|(c, _)| c) == Some(col_idx)
                    }) {
                        self.send_action(Action::FocusWindow { id: w.id })?;
                        // SetProportion takes a percentage (0–100), not a fraction
                        self.send_action(Action::SetColumnWidth {
                            change: SizeChange::SetProportion(50.0),
                        })?;
                    }
                }

                // Viewport is now at x=0 (left column reset it). However
                // FocusColumnRight uses niri's internal layout positions, which
                // may not yet reflect col 1's new position (it shifts left when
                // col 0 shrinks). A round-trip query forces niri to finish all
                // pending layout recalculation before we send the focus action,
                // so col 1's position is correct and no viewport scroll occurs.
                let _ = self.query_full_state();
                let _ = self.send_action(Action::FocusColumnRight {});
            }
            _ => {
                // 3+ columns: new windows open at default-column-width (1.0), scrollable
                debug!("workspace {}: {} columns, doing nothing", ws_id, column_count);
            }
        }

        Ok(())
    }

    fn handle_event(&mut self, event: Event) -> Result<()> {
        let mut affected_workspaces = Vec::new();

        match event {
            Event::WindowsChanged { windows } => {
                debug!("full windows change event received");
                let mut new_tracked = HashMap::with_capacity(windows.len());

                for w in windows {
                    if !w.is_floating {
                        if let Some(ws_id) = w.workspace_id {
                            if let Some((col, tile)) = w.layout.pos_in_scrolling_layout {
                                let pos = WindowPosition { workspace_id: ws_id, column: col, tile };
                                new_tracked.insert(w.id, pos);
                            }
                        }
                    }
                }

                for (&id, &pos) in &new_tracked {
                    if self.tracked_window_positions.get(&id) != Some(&pos) {
                        affected_workspaces.push(pos.workspace_id);
                    }
                }
                for (&id, &pos) in &self.tracked_window_positions {
                    if new_tracked.get(&id) != Some(&pos) {
                        affected_workspaces.push(pos.workspace_id);
                    }
                }

                self.tracked_window_positions = new_tracked;
            }

            Event::WindowOpenedOrChanged { window } => {
                let id = window.id;
                let ws_id_opt = window.workspace_id;
                let is_floating = window.is_floating;
                let old_pos = self.tracked_window_positions.get(&id).copied();

                if is_floating {
                    if let Some(pos) = old_pos {
                        self.tracked_window_positions.remove(&id);
                        affected_workspaces.push(pos.workspace_id);
                    }
                } else if let Some(ws_id) = ws_id_opt {
                    // Always re-evaluate the destination workspace, even if layout
                    // position isn't assigned yet (e.g. window just moved workspaces)
                    affected_workspaces.push(ws_id);

                    if let Some((col, tile)) = window.layout.pos_in_scrolling_layout {
                        let new_pos = WindowPosition { workspace_id: ws_id, column: col, tile };
                        if old_pos != Some(new_pos) {
                            self.tracked_window_positions.insert(id, new_pos);
                            if let Some(old) = old_pos {
                                if old.workspace_id != ws_id {
                                    affected_workspaces.push(old.workspace_id);
                                }
                            }
                        }
                    } else if let Some(old) = old_pos {
                        if old.workspace_id != ws_id {
                            affected_workspaces.push(old.workspace_id);
                        }
                    }
                }
            }

            Event::WindowLayoutsChanged { changes } => {
                for (id, layout) in changes {
                    if let Some(pos) = self.tracked_window_positions.get_mut(&id) {
                        if let Some((col, tile)) = layout.pos_in_scrolling_layout {
                            if pos.column != col || pos.tile != tile {
                                pos.column = col;
                                pos.tile = tile;
                                affected_workspaces.push(pos.workspace_id);
                            }
                        }
                    }
                }
            }

            Event::WindowClosed { id } => {
                if let Some(pos) = self.tracked_window_positions.remove(&id) {
                    info!("window {} closed, re-evaluating ws {}", id, pos.workspace_id);
                    affected_workspaces.push(pos.workspace_id);
                }
            }

            _ => {}
        }

        if !affected_workspaces.is_empty() {
            affected_workspaces.sort_unstable();
            affected_workspaces.dedup();

            let state = self.query_full_state()?;
            let windows_map: HashMap<u64, &Window> =
                state.windows.iter().map(|w| (w.id, w)).collect();

            for ws_id in affected_workspaces {
                if let Err(e) = self.evaluate_workspace(ws_id, &state, &windows_map) {
                    error!("error evaluating workspace {}: {:?}", ws_id, e);
                }
            }
        }

        Ok(())
    }
}

fn main() -> Result<()> {
    env_logger::Builder::from_env(env_logger::Env::default().default_filter_or("info")).init();
    info!("niri-autotile: starting");

    loop {
        if let Err(e) = run_event_loop() {
            error!("fatal error in event loop: {:?}. reconnecting in 5 seconds...", e);
            std::thread::sleep(std::time::Duration::from_secs(5));
        }
    }
}

fn run_event_loop() -> Result<()> {
    let mut context = NiriContext::new().context("failed to initialize NiriContext")?;

    let mut event_socket = Socket::connect().context("connecting to niri event stream")?;
    let _ = event_socket
        .send(Request::EventStream)
        .context("failed to request event stream")?;
    let mut read_event = event_socket.read_events();

    info!("connected to niri; performing initial sync");
    let state = context.query_full_state().context("initial state query failed")?;
    context.handle_event(Event::WindowsChanged { windows: state.windows })?;

    loop {
        let event = match read_event().context("reading event from niri") {
            Ok(ev) => ev,
            Err(e) => {
                error!("error reading from event socket: {:?}. reconnecting...", e);
                return Err(e);
            }
        };

        if let Err(e) = context.handle_event(event) {
            error!("error handling event: {:?}", e);
            if e.to_string().contains("connection") || e.to_string().contains("socket") {
                return Err(e);
            }
        }
    }
}
