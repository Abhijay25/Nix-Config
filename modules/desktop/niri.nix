{ ... }: {
  # Niri compositor
  programs.niri.enable = true;

  # X server (for XWayland compatibility)
  services.xserver.enable = true;
}
