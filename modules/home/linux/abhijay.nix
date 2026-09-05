{
  inputs,
  pkgs,
  ...
}: {
  home.username = "abhijay";
  home.homeDirectory = "/home/abhijay";
  home.stateVersion = "25.11";

  imports = [
    ../shared/shell.nix
    ../shared/packages.nix
    ../shared/nixvim.nix
    ./desktop.nix
    ./packages.nix
  ];

  # home-manager now ships its own programs.noctalia module, so import only
  # the package from the flake to stay on the upstream-tracking version.
  programs.noctalia = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
  home.enableNixpkgsReleaseCheck = false;
}
