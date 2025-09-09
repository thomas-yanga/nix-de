{
  description = "NixOS configuration with USTC mirrors";

  inputs = {
    nixpkgs.url = "https://githubfast.com/NixOS/nixpkgs/archive/nixos-25.05.tar.gz";
    home-manager.url = "https://githubfast.com/nix-community/home-manager/archive/release-25.05.tar.gz";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      "nix-de" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
        ];
      };
    };
  };
}

