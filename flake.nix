{
  description = "NixOS on Thinkpad";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
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

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    crane,
    ...
  }: {
    nixosConfigurations.doge = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware-configuration.nix
        ./modules
        home-manager.nixosModules.home-manager
        {
          nixpkgs.overlays = [
            (final: _: {
              niri-autotile = final.callPackage ./pkgs/niri-autotile {
                craneLib = crane.mkLib final;
              };
            })
          ];
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users.abhijay = import ./modules/users/abhijay.nix;
            backupFileExtension = "backup";
          };
        }
      ];
    };
  };
}
