{
  description = "My Nix, NixOS and Home-Manager config based on flakes.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Import all systems from the systems input
      systems = import inputs.systems;

      # Import flake modules
      imports = [
        ./flake-modules/devshells.nix
        ./flake-modules/formatter.nix
        ./flake-modules/checks.nix
      ];

      # Configure per-system settings
      perSystem = { pkgs, system, ... }: {
        # Allow unfree packages for all systems
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };

      # Flake-level outputs (machine-specific configurations)
      flake = {
        nixosConfigurations = {
          nixos-workstation = inputs.nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
              outputs = self;
            };
            modules = [
              ./hosts/nixos-workstation/configuration.nix
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.backupFileExtension = "bkp";
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.hugomvs = import ./hosts/nixos-workstation/home.nix;
              }
            ];
          };
        };

        homeConfigurations = let
          mkHomeConfig = { system, username, homeDirectory, configPath }:
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
        in {
          wsl = mkHomeConfig {
            system = "x86_64-linux";
            username = "hugo";
            homeDirectory = "/home/hugo";
            configPath = ./hosts/wsl/home.nix;
          };

          ubuntu = mkHomeConfig {
            system = "x86_64-linux";
            username = "hugo";
            homeDirectory = "/home/hugo";
            configPath = ./hosts/ubuntu/home.nix;
          };
        };
      };
    };
}
