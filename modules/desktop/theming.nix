{ pkgs, ... }: {
  # Fonts
  fonts.packages = with pkgs; [
    inter
    nerd-fonts.jetbrains-mono
    roboto
  ];

  # File manager
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs; [
    thunar-archive-plugin
    thunar-volman
  ];

  # Services for Thunar
  services.gvfs.enable = true;    # USB mounting
  services.tumbler.enable = true; # Thumbnails
}
