{ ... }: {
  imports = [
    # Core
    ../../modules/darwin/core/nix.nix
    ../../modules/darwin/core/system.nix
    ../../modules/darwin/core/packages.nix

    # Programs
    ../../modules/darwin/programs/shell.nix

    # Homebrew (GUI apps)
    ../../modules/darwin/homebrew.nix
  ];
}
