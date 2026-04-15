{ inputs, ... }:
{
  flake.nixosConfigurations = {
    nixos-kot225 = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ inputs.self.modules.nixos.nixosKot225Configuration ];
    };
  };
}
