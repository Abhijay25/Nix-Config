{ pkgs, ... }: {
  home.packages = with pkgs; [
    # System
    gcc
    hyprpolkitagent
    hyprshell
    engrampa

    # Terminal
    fastfetch

    # Quality of Life
    brightnessctl
    libnotify
    pamixer
    playerctl

    # Wayland Utilities
    grim
    satty
    slurp
    wl-clipboard

    # Ricing & Themes

    # Applications
    qgis
    (chromium.override {
      commandLineArgs = [
        "--ozone-platform=wayland"
        "--enable-features=UseOzonePlatform"
      ];
    })
    localsend
    telegram-desktop
    vesktop
    spotify

    # Wayland/ozone and VA-API flags are applied by the nixpkgs wrapper itself
    # (driven by NIXOS_OZONE_WL), so no override is needed here.
    brave
  ];
}
