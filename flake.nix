{
  description = "NixOS + nix-darwin dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    crane.url = "github:ipetkov/crane";
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Declared for future perSystem outputs (devShells, packages, etc.)
      systems = [ "x86_64-linux" "aarch64-darwin" ];

      flake = {
        nixosConfigurations.doge = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/doge
            inputs.home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [
                (final: _: {
                  niri-autotile = final.callPackage ./pkgs/niri-autotile {
                    craneLib = inputs.crane.mkLib final;
                  };
                })
              ];
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users.abhijay = import ./modules/home/linux/abhijay.nix;
                backupFileExtension = "backup";
              };
            }
          ];
        };

        # Uncomment when Mac arrives. Set hostname to match `scutil --get LocalHostName`.
        # darwinConfigurations.mac = inputs.nix-darwin.lib.darwinSystem {
        #   specialArgs = { inherit inputs; };
        #   modules = [
        #     ./hosts/mac
        #     inputs.home-manager.darwinModules.home-manager
        #     {
        #       home-manager = {
        #         useGlobalPkgs = true;
        #         useUserPackages = true;
        #         extraSpecialArgs = { inherit inputs; };
        #         users.abhijay = import ./modules/home/darwin/abhijay.nix;
        #         backupFileExtension = "backup";
        #       };
        #     }
        #   ];
        # };
      };
    };
}
