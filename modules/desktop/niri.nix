{ pkgs, ... }: {
  # Niri compositor
  programs.niri.enable = true;

  # XWayland support via xwayland-satellite
  environment.systemPackages = [ pkgs.xwayland-satellite ];
}
