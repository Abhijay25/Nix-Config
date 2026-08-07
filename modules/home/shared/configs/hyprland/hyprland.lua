local mainMod = "SUPER"

-- Monitor
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1.25,
})

-- Startup
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("sleep 2 && hyprshell run")
end)

-- Input
hl.config({
    input = {
        kb_layout    = "us",
        repeat_rate  = 35,
        repeat_delay = 200,
        follow_mouse = 1,
        accel_profile = "flat",
        touchpad = {
            tap_to_click = true,
        },
    },
})

-- Layout & Decoration
hl.config({
    general = {
        gaps_in     = 3,
        gaps_out    = 5,
        border_size = 2,
        col = {
            active_border   = "rgb(7fc8ff)",
            inactive_border = "rgb(505050)",
        },
        layout = "dwindle",
    },

    decoration = {
        rounding = 4,
        blur = {
            enabled           = true,
            size              = 4,
            passes            = 2,
            new_optimizations = true,
            xray              = false,
            noise             = 0.02,
            popups            = true,
        },
        shadow = {
            enabled = false,
        },
        dim_inactive = true,
        dim_strength = 0.05,
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("emphasizedDecel", { type = "bezier", points = { {0.05, 0.7},  {0.1, 1}     } })
hl.curve("emphasizedAccel", { type = "bezier", points = { {0.3, 0},     {0.8, 0.15}  } })
hl.curve("overshot",        { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.05}  } })
hl.curve("menu_decel",      { type = "bezier", points = { {0.1, 1},     {0, 1}       } })
hl.curve("menu_accel",      { type = "bezier", points = { {0.52, 0.03}, {0.72, 0.08} } })
hl.curve("liner",           { type = "bezier", points = { {1, 1},       {1, 1}       } })

hl.animation({ leaf = "windowsIn",     enabled = true, speed = 3,   bezier = "emphasizedDecel", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 2,   bezier = "emphasizedDecel", style = "popin 90%" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 3,   bezier = "emphasizedDecel", style = "slide" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 3,   bezier = "emphasizedDecel" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 2,   bezier = "emphasizedDecel" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 2.7, bezier = "emphasizedDecel", style = "popin 93%" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 2.4, bezier = "menu_accel",      style = "popin 94%" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 0.5, bezier = "menu_decel" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2.7, bezier = "liner" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 5,   bezier = "menu_decel",      style = "slide" })
hl.animation({ leaf = "border",        enabled = true, speed = 1,   bezier = "liner" })

-- Keybindings — General
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("brave --disable-background-networking --disable-component-update"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + Backspace", hl.dsp.exec_cmd("noctalia msg panel-toggle session"))

-- Screenshots
-- --freeze grabs the frame before slurp takes its input grab, so hover menus and
-- other focus-sensitive popups survive into the shot. --cursor keeps the pointer.
hl.bind("Print", hl.dsp.exec_cmd([[grimblast --freeze --cursor copy area]]))
hl.bind("CTRL + Print", hl.dsp.exec_cmd([[GRIMBLAST_EDITOR="satty --filename" grimblast --freeze --cursor edit area]]))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd([[grimblast --freeze --cursor --notify copysave area ~/Pictures/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png]]))

-- Focus (vim-style)
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))

-- Move window to monitor
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ monitor = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ monitor = "r" }))

-- Focus monitor
hl.bind(mainMod .. " + left",  hl.dsp.focus({ monitor = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ monitor = "r" }))

-- Workspaces — switch / move window
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,           hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i,   hl.dsp.window.move({ workspace = i }))
end

-- Floating / fullscreen
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("ALT + Return", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

-- Alt-Tab via hyprshell (keybindings configured in ~/.config/hyprshell/config.ron)

-- Media & brightness keys
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"))
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("pamixer -d 5"),            { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("pamixer -i 5"),            { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"),   { locked = true, repeating = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pamixer --default-source -t"))

-- Window rules
local floatingClasses = {
    "^(com\\.gabm\\.satty)$",
    "^(xdg-desktop-portal)(.*)$",
    "^(polkit-gnome-.*)$",
    "^(nm-connection-editor)$",
    "^(pavucontrol)$",
    "^(blueman-.*)$",
    "^(engrampa)$",
    "^(file-roller)$",
    "^(seahorse)$",
    "^(pinentry.*)$",
}

for i, class in ipairs(floatingClasses) do
    hl.window_rule({
        name  = "float-" .. i,
        match = { class = class },
        float = true,
    })
end
