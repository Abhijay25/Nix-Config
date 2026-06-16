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

    (brave.override {
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
        "--enable-gpu-rasterization"
        "--enable-zero-copy"
        "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization"
      ];
    })
  ];
}
