{ inputs }:
let
  specialArgs = { inherit inputs; };
in
{
  # Cria uma configuração NixOS para um host a partir da sua subpasta _<hostname>/.
  # A subpasta deve conter:
  #   - hardware-configuration.nix  (gerado por nixos-generate-config)
  #   - configuration.nix           (lista de aspects dendritic a incluir)
  #   - home.nix                    (aspects home-manager do utilizador)
  mkHost = { hostname, system ? "x86_64-linux" }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        ./_${hostname}/hardware-configuration.nix
        ./_${hostname}/configuration.nix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bkp";
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.hugomvs = import ./_${hostname}/home.nix;
        }
      ];
    };

  # Cria uma configuração home-manager standalone para sistemas não-NixOS.
  # A subpasta _<hostname>/ deve conter apenas home.nix.
  # A chave em homeConfigurations deve ser o username (compatível com $(whoami)).
  mkHome = { hostname, system ? "x86_64-linux" }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      extraSpecialArgs = specialArgs;
      modules = [ ./_${hostname}/home.nix ];
    };
}
