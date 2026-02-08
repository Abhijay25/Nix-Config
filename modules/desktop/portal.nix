{ pkgs, ... }: {
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config = {
      niri.default = [ "gnome" "gtk" ];
      common.default = [ "gtk" ];
    };
  };
}
