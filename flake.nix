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

      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

    in {

      nixosConfigurations = {
        nixos-workstation = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/nixos-workstation/configuration.nix ];
        };
      };

      homeConfigurations = {
        "hugomvs@nixos-workstation" =
          home-manager.lib.homeManagerConfiguration {
            pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
            extraSpecialArgs = { inherit inputs outputs; };
            modules = [ ./modules/home-manager/home.nix ];
          };
      };

    };
}
