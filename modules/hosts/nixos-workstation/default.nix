{ inputs, ... }:
{
  flake.nixosConfigurations = {
    nixos-workstation = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ inputs.self.modules.nixos.nixosWorkstationConfiguration ];
    };
  };
}
