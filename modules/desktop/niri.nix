{ ... }: {
  # Niri compositor
  programs.niri.enable = true;

  # Required for XWayland
  services.xserver.enable = true;
}
