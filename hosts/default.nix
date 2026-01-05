{ inputs, outputs, self, ... }:
{
  flake = {
    nixosConfigurations = {
      nixos-workstation = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs self; };
        system = "x86_64-linux";
        modules = [
          ./nixos-workstation/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "bkp";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit self; };
            home-manager.users.hugomvs = import ./nixos-workstation/home.nix;
          }
        ];
      };
      nixos-notebook = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs self; };
        system = "x86_64-linux";
        modules = [
          ./nixos-notebook/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "bkp";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit self; };
            home-manager.users.hugomvs = import ./nixos-notebook/home.nix;
          }
        ];
      };
    };

    homeConfigurations = {
      "hugom@kot225" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit self; };
        modules = [
          ./wsl/home.nix
        ];
      };
    };
  };
}
