{ pkgs, ...}:

{
  home.packages = [
    # (import ./updateSystem.nix { inherit pkgs; })
    # (import ./rebuildHome.nix { inherit pkgs; })
    # (import ./rebuildSystem.nix { inherit pkgs; })

    (import ./tmuxSessionizer.nix { inherit pkgs; })
    (import ./tmuxWorktreeSessionizer.nix { inherit pkgs; })
    (import ./spawnTmux.nix { inherit pkgs; })

    (import ./llmChat.nix { inherit pkgs; })

    (import ./dunstToggle.nix { inherit pkgs; })
    (import ./powerMenu.nix { inherit pkgs; })
    (import ./screenShotToPinta.nix { inherit pkgs; })
    (import ./githubClone.nix { inherit pkgs; })
  ];
}
