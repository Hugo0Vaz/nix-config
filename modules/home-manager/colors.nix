{ lib, ... }:
{
  # Stylix is configured at the NixOS level in modules/nixos/stylix
  # This ensures system-wide theming consistency
  
  # Disable Stylix auto-theming for programs we manually configure
  stylix.targets = {
    waybar.enable = false;
    wofi.enable = false;
    vim.enable = false;
    tmux.enable = false;
    fish.enable = false;
    starship.enable = false;
    obsidian.enable = true;
  };

  # Configure Obsidian vault names for Stylix
  stylix.targets.obsidian.vaultNames = [ "30_obsidian" ];
}
