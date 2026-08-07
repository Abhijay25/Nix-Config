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
    telegram-desktop
    vesktop
    spotify

    # Wayland/ozone and VA-API flags are applied by the nixpkgs wrapper itself
    # (driven by NIXOS_OZONE_WL), so no override is needed here.
    brave
  ];
}
