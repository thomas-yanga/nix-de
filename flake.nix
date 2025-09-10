{
  description = "NixOS configuration with mirrors";

  inputs = {
    #nixpkgs.url = "https://githubfast.com/NixOS/nixpkgs/archive/nixos-25.05.tar.gz";
    #nixpkgs-unstable.url = "https://githubfast.com/NixOS/nixpkgs/nixos-unstable";
    #home-manager.url = "https://githubfast.com/nix-community/home-manager/archive/release-25.05.tar.gz";

    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    #nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    #home-manager.url = "github:nix-community/home-manager/release-25.05";

    #nixpkgs.url = "https://mirrors.ustc.edu.cn/git/nixpkgs.git?ref=nixos-25.05";
    #nixpkgs-unstable.url = "https://mirrors.ustc.edu.cn/git/nixpkgs.git?ref=nixos-unstable";
    #home-manager.url = "https://mirrors.ustc.edu.cn/git/home-manager.git?ref=release-25.05";

    nixpkgs.url = "file:///home/yangdi/nixos-config/tmp/nixpkgs-nixos-25.05.tar.gz";
    nixpkgs-unstable.url = "file:///home/yangdi/nixos-config/tmp/nixos-unstable.tar.gz";
    home-manager.url = "file:///home/yangdi/nixos-config/tmp/home-manager-release-25.05.tar.gz";
    # Make home-manager use the same nixpkgs as the system
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      # System architecture
      system = "x86_64-linux";

      # Import unstable channel with unfree packages allowed
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # NixOS configuration for host "nix-de"
      nixosConfigurations = {
        "nix-de" = nixpkgs.lib.nixosSystem {
          inherit system;

          # Pass unstable package set as a special argument
          specialArgs = { inherit unstable; };

          modules = [
            # Main system configuration
            ./configuration.nix

            # Home Manager integration
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # Pass unstable package set to home-manager
              home-manager.extraSpecialArgs = { inherit unstable; };
            }
          ];
        };
      };
    };
}
