{ inputs, ... }:
{
  flake.nixosConfigurations = {
    nixos-workstation = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        outputs = inputs.self;
      };
      modules = [
        ../../../hosts/nixos-workstation/configuration.nix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.backupFileExtension = "bkp";
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.hugomvs = import ../../../hosts/nixos-workstation/home.nix;
        }
      ];
    };
  };

  flake.homeConfigurations =
    let
      mkHomeConfig =
        {
          system,
          username,
          homeDirectory,
          configPath,
        }:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = [
            configPath
            {
              home.username = username;
              home.homeDirectory = homeDirectory;
            }
          ];
        };
    in
    {
      wsl = mkHomeConfig {
        system = "x86_64-linux";
        username = "hugo";
        homeDirectory = "/home/hugo";
        configPath = ../../../hosts/wsl/home.nix;
      };

      ubuntu = mkHomeConfig {
        system = "x86_64-linux";
        username = "hugo";
        homeDirectory = "/home/hugo";
        configPath = ../../../hosts/ubuntu/home.nix;
      };
    };
}
