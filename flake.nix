{
  description = "My Nix, NixOS and Home-Manager config based on flakes.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-ai-tools.url = "github:numtide/nix-ai-tools";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let

      inherit (self) outputs;

    in {
      nixosConfigurations = {
        nixos-workstation = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/nixos-workstation/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.backupFileExtension = "bkp";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.hugomvs = import ./hosts/nixos-workstation/home.nix;
            }
          ];
        };
      };

      homeConfigurations = {
        wsl = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { 
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          modules = [
            ./hosts/wsl/home.nix
            {
              home.username = "hugo";
              home.homeDirectory = "/home/hugo";
            }
          ];
        };
        ubuntu = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { 
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          modules = [
            ./hosts/ubuntu/home.nix
            {
              home.username = "hugo";
              home.homeDirectory = "/home/hugo";
            }
          ];
        };
      };
    };
}
