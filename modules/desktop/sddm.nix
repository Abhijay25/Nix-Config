{ pkgs, ... }: {
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.sddm;
    theme = "sddm-astronaut-theme";

    extraPackages = with pkgs.kdePackages; [
      qtmultimedia
      qtsvg
      qtvirtualkeyboard
      qt5compat
    ];
  };

  # SDDM theme
  environment.systemPackages = with pkgs; [
    (sddm-astronaut.override {
      themeConfig = {
        MainColor = "#ffbbbd";
        AccentColor = "#ffbbbd";
        showPowerButton = "true";
      };
      embeddedTheme = "pixel_sakura";
    })
  ];
}
