{ pkgs, ...}:

{
  home.packages = [
    (import ./rebuildSystem.nix { inherit pkgs; })
    (import ./tmuxSessionizer.nix { inherit pkgs; })
    (import ./spawnTmux.nix { inherit pkgs; })
    (import ./updateSystem.nix { inherit pkgs; })
    (import ./rebuildHome.nix { inherit pkgs; })
    (import ./llmChat.nix { inherit pkgs; })
    (import ./dunstToggle.nix { inherit pkgs; })
  ];
}
