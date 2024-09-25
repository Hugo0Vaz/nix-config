{ pkgs, ...}:

{
  home.packages = [
    (import ./rebuildSystem.nix { inherit pkgs; })
    (import ./tmux-sessionizer.nix { inherit pkgs; })
    (import ./spawnTmux.nix { inherit pkgs; })
  ];
}
