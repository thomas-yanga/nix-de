{
  description = "NixOS configuration with USTC mirrors";

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
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      system = "x86_64-linux";
      # 创建 unstable pkgs 实例，允许非自由软件
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        "nix-de" = nixpkgs.lib.nixosSystem {
          inherit system;
          # 将 unstable 作为特殊参数传递
          specialArgs = { inherit unstable; };
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # 也将 unstable 传递给 home-manager
              home-manager.extraSpecialArgs = { inherit unstable; };
            }
          ];
        };
      };
    };
}
