{ inputs, ... }:
{

  imports = [
    inputs.stylix.homeModules.stylix
  ];

  stylix.targets = {
    # Disable targets we manually configure
    waybar.enable = false;
    wofi.enable = false;
    vim.enable = false;
    tmux.enable = false;
    fish.enable = false;
    starship.enable = false;
    
    # Enable application theming
    gtk.enable = true;
    kde.enable = true;
    firefox.enable = true;
    obsidian.enable = true;
  };

  stylix.targets.obsidian.vaultNames = [ "30_obsidian" ];

  # Configure GTK to use dark theme preference
  gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Configure Qt to use dark theme
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };

  # Set dark mode preference for applications
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
