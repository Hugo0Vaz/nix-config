{ pkgs, ...}:

{
  home.packages = [
    (import ./rebuildSystem.nix { inherit pkgs; })
    (import ./tmuxSessionizer.nix { inherit pkgs; })
    (import ./spawnTmux.nix { inherit pkgs; })
    (import ./updateSystem.nix { inherit pkgs; })
  ];
}
