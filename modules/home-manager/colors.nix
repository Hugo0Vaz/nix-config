{ inputs, ... }:
{

  imports = [
    inputs.stylix.homeModules.stylix
  ];

  stylix.targets = {
    waybar.enable = false;
    wofi.enable = false;
    vim.enable = false;
    tmux.enable = false;
    fish.enable = false;
    starship.enable = false;
    obsidian.enable = true;
  };

  stylix.targets.obsidian.vaultNames = [ "30_obsidian" ];
}
