{ pkgs, ... }: {
  home.packages = with pkgs; [
    # System
    gcc
    hyprpolkitagent
    hyprshell
    engrampa
    libsecret

    # Terminal
    fastfetch

    # Quality of Life
    brightnessctl
    libnotify
    pamixer
    playerctl

    # Wayland Utilities
    grim
    # grimblast --freeze captures the screen before slurp takes its input grab,
    # so hover menus survive into the screenshot. hyprpicker renders the freeze.
    grimblast
    hyprpicker
    satty
    slurp
    wl-clipboard

    # Ricing & Themes

    # Applications
    # pyqt6-webengine is not in the qgis closure, so qgis2web's embedded webmap
    # preview stays disabled. Its "Install new Browser" button shells out to
    # `sudo apt-get install python3-pyqt6.qtwebengine` and calls os._exit(0)
    # when that fails, which makes QGIS vanish on NixOS. Supplying the
    # dependency declaratively is the only fix that survives a GC.
    (qgis.override { extraPythonPackages = ps: [ ps.pyqt6-webengine ]; })
    (chromium.override {
      commandLineArgs = [
        "--ozone-platform=wayland"
        "--enable-features=UseOzonePlatform"
      ];
    })
    localsend
    obsidian

    # SUPER+R toggle. gpu-screen-recorder finalises the mp4 on SIGINT, so the
    # same key starts and stops. Unqualified on purpose: the binary must come
    # from PATH so it resolves to the setcap wrapper that
    # programs.gpu-screen-recorder installs, not the raw store path. Output goes
    # to ~/Videos/Recordings to match the noctalia widget default, so both
    # frontends drop files in the same place.
    #
    # The PID is tracked in a file rather than matched with pkill. The kernel
    # truncates comm to 15 chars ("gpu-screen-reco"), so pkill -x on the real
    # name silently matches nothing, and pkill -f would match any shell whose
    # command line mentions the binary — including this script's own caller.
    # $$ survives exec, so the pre-exec shell writes the PID the recorder ends
    # up owning. This also leaves the noctalia widget's own recordings alone.
    (pkgs.writeShellScriptBin "gsr-toggle" ''
      pidfile="''${XDG_RUNTIME_DIR:-/tmp}/gsr-toggle.pid"

      if [ -r "$pidfile" ]; then
        pid=$(cat "$pidfile")
        # Verify it is still our recorder before signalling: PIDs get reused.
        if [ -n "$pid" ] && [ "$(cat /proc/"$pid"/comm 2>/dev/null)" = "gpu-screen-reco" ]; then
          kill -INT "$pid"
          rm -f "$pidfile"
          ${pkgs.libnotify}/bin/notify-send "Screen Recorder" "Recording stopped"
          exit 0
        fi
        rm -f "$pidfile"
      fi

      # "-w focused" needs an explicit -s WxH, so resolve the focused output to
      # its name instead and let the recorder take the size from it.
      monitor=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r \
        'map(select(.focused)) | .[0].name // empty')
      if [ -z "$monitor" ]; then
        monitor=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[0].name')
      fi

      mkdir -p "$HOME/Videos/Recordings"
      echo $$ > "$pidfile"
      ${pkgs.libnotify}/bin/notify-send "Screen Recorder" "Recording started"
      exec gpu-screen-recorder -w "$monitor" -f 60 -a default_output \
        -o "$HOME/Videos/Recordings/recording-$(date +%F_%H-%M-%S).mp4"
    '')
    telegram-desktop
    vesktop
    spotify

    # Wayland/ozone and VA-API flags are applied by the nixpkgs wrapper itself
    # (driven by NIXOS_OZONE_WL), so no override is needed here.
    brave
  ];
}
