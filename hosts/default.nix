{ inputs, outputs, self, ... }:
let
  specialArgs = { inherit inputs outputs self; };
in 
{
  flake = {
    nixosConfigurations = {

      nixos-workstation = inputs.nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./nixos-workstation/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "bkp";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.hugomvs = import ./nixos-workstation/home.nix;
          }
        ];
      };

      nixos-notebook = inputs.nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./nixos-notebook/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "bkp";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.hugomvs = import ./nixos-notebook/home.nix;
          }
        ];
      };
    };

    homeConfigurations = {

      hugom = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = specialArgs;
        modules = [
          ./wsl/home.nix
        ];
      };

    };
  };
}
