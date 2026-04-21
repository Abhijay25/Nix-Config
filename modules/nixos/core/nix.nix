{ ... }: {
  # Allow proprietary packages
  nixpkgs.config.allowUnfree = true;

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    max-jobs = 8;  # One job per core — uses all 8 cores
    cores = 1;     # Each job gets 1 core; avoids contention across parallel builds

    # Restrict nix operations to wheel group
    allowed-users = [ "@wheel" ];
    trusted-users = [ "root" "@wheel" ];

    # Binary caches for faster builds
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

  };

  # Use batch scheduling for good balance between rebuild speed and system responsiveness
  # batch = rebuilds run at lower priority, won't slow down active apps
  nix.daemonCPUSchedPolicy = "batch";

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
    persistent = true;
  };

  system.stateVersion = "25.11";
}
