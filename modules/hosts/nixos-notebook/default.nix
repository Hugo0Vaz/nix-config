{ inputs, ... }:
{
  flake.nixosConfigurations = {
    nixos-notebook = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ inputs.self.modules.nixos.nixosNotebookConfiguration ];
    };
  };
}
