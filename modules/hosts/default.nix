{ inputs, outputs, config, ... }:
{
  flake = {
    nixosConfigurations = {
      nixos-workstation = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        system = "x86_64-linux";
        modules = [
          ./nixos-workstation/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "bkp";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.hugomvs = import ./nixos-workstation/home.nix;
          }
        ];
      };
    };

    homeConfigurations = {
      wsl = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs { 
            system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [
          ./wsl/home.nix
        ];
      };
    };
  };
}
