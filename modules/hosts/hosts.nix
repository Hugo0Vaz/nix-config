{ inputs, ... }:
let
  lib' = import ./_lib.nix { inherit inputs; };
in
{
  flake.nixosConfigurations = {
    nixos-workstation = lib'.mkHost { hostname = "nixos-workstation"; };
    nixos-notebook    = lib'.mkHost { hostname = "nixos-notebook"; };
  };

  flake.homeConfigurations = {
    hugom = lib'.mkHome { hostname = "wsl"; };
  };
}
