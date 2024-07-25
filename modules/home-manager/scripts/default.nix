{ config, pkgs, ...}:

{
  # home.file.".local/scripts/" = {
  #   source = ./../../../dotfiles/scripts/.local/scripts;
  #   recursive = true;
  #   executable = true;
  # };

  home.packages = [
    (import ./rebuildSystem.nix { inherit pkgs; })
    pkgs.writeShellScriptBin "tmux-sessionizer" (builtins.readFile ./../../../dotfiles/scripts/.local/scripts/tmux-sessionizer.sh)
  ];
}
