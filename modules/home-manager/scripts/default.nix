{ pkgs, ...}:

{
  home.packages = [
    (import ./rebuildSystem.nix { inherit pkgs; })
    # (import ./tmux-sessionizer.nix { inherit pkgs; })
  ];
}
