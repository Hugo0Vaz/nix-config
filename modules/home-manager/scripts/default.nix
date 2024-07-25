{ config, pkgs, ...}:

{
  home.file.".local/scripts/" = {
    source = ./../../../dotfiles/scripts/.local/scripts;
    recursive = true;
    executable = true;
  };

  home.packages = [
    (import ./rebuildSystem.nix { inherit pkgs; })
  ];
}
