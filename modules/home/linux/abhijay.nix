{
  inputs,
  ...
}: {
  home.username = "abhijay";
  home.homeDirectory = "/home/abhijay";
  home.stateVersion = "25.11";

  imports = [
    inputs.noctalia.homeModules.default
    ../shared/shell.nix
    ../shared/packages.nix
    ../shared/nixvim.nix
    ./desktop.nix
    ./packages.nix
  ];

  programs.noctalia.enable = true;
  home.enableNixpkgsReleaseCheck = false;
}
