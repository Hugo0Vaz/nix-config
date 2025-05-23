{
  description = "My Nix, NixOS and Home-Manager config based on flakes.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    };
}
