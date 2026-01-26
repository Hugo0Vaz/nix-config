{ inputs, pkgs, flakeRoot, lib, ... }:
{
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  # Base Stylix configuration
  stylix = {
    enable = true;
    # Gruvbox Dark color scheme
    base16Scheme = {
      base00 = "282828";
      base01 = "3c3836";
      base02 = "504945";
      base03 = "665c54";
      base04 = "bdae93";
      base05 = "d5c4a1";
      base06 = "ebdbb2";
      base07 = "fbf1c7";
      base08 = "fb4934";
      base09 = "fe8019";
      base0A = "fabd2f";
      base0B = "b8bb26";
      base0C = "8ec07c";
      base0D = "83a598";
      base0E = "d3869b";
      base0F = "d65d0e";
    };

    cursor = {
      package = pkgs.kdePackages.breeze;
      name = "breeze_cursors";
      size = 24;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sizes = {
        applications = 12;
        terminal = 12;
        desktop = 10;
        popups = 10;
      };
    };

    opacity = {
      applications = 1.0;
      terminal = 0.95;
      desktop = 1.0;
      popups = 1.0;
    };
  };

  # Application-specific theming targets
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
    firefox.enable = true;
    obsidian.enable = true;
  };

  stylix.targets.obsidian.vaultNames = [ "30_obsidian" ];

  # GTK dark theme configuration
  gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Qt dark theme configuration
  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "gtk3";
    style.name = lib.mkForce "adwaita-dark";
  };

  # Set dark mode preference for applications
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = lib.mkForce "prefer-dark";
    };
  };
}
