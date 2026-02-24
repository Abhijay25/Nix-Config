{ ... }: {
  # Allow proprietary packages
  nixpkgs.config.allowUnfree = true;

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    max-jobs = 4;  # Build up to 4 packages in parallel
    cores = 2;     # Each package can use up to 2 cores (4*2=8 total)

    # Restrict nix operations to wheel group
    allowed-users = [ "@wheel" ];
    trusted-users = [ "root" "@wheel" ];

    # Binary caches for faster builds
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];

    # Evaluation optimizations
    eval-cache = true;
    keep-outputs = false;
    keep-derivations = false;
  };

  # Use batch scheduling for good balance between rebuild speed and system responsiveness
  # batch = rebuilds run at lower priority, won't slow down active apps
  nix.daemonCPUSchedPolicy = "batch";

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  system.stateVersion = "25.11";
}
