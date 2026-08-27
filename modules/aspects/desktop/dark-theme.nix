{
  # Default dark theme for Qt and GTK applications, applied on every host with a
  # desktop session (Niri and/or KDE Plasma). The values are kept as
  # `my.darkTheme.*` options so hosts can override them without touching this
  # aspect.
  #
  # GTK: a dark theme (Adwaita-dark) plus the "prefer dark" color scheme, which
  #      covers GTK 3 and GTK 4/libadwaita (the latter via the Settings portal).
  # Qt:  fully declarative dark, with no dependency on Plasma's color scheme.
  #      The `adwaita-dark` widget style (QT_STYLE_OVERRIDE) renders dark purely
  #      from Nix and matches GTK's Adwaita-dark; the `kde` platform theme keeps
  #      KDE fonts, icons and file dialogs (including under Niri).
  flake.modules.nixos.dark-theme =
    { inputs, pkgs, lib, config, ... }:
    {
      options.my.darkTheme = {
        gtkThemeName = lib.mkOption {
          type = lib.types.str;
          default = "Adwaita-dark";
          description = "GTK theme to use (must be a dark variant).";
        };

        gtkThemePackage = lib.mkOption {
          type = lib.types.package;
          default = pkgs.gnome-themes-extra;
          description = "Package providing the GTK theme (for GTK 2 support).";
        };

        qtPlatformTheme = lib.mkOption {
          type = lib.types.str;
          default = "kde";
          description = "Qt platform theme (QT_QPA_PLATFORMTHEME), for KDE fonts/icons/dialogs integration.";
        };

        qtStyle = lib.mkOption {
          type = lib.types.str;
          default = "adwaita-dark";
          description = "Qt widget style (QT_STYLE_OVERRIDE); this carries the dark color scheme.";
        };
      };

      config = {
        home-manager.sharedModules = [
          inputs.self.modules.homeManager.dark-theme
          {
            my.darkTheme.gtkThemeName = config.my.darkTheme.gtkThemeName;
            my.darkTheme.gtkThemePackage = config.my.darkTheme.gtkThemePackage;
            my.darkTheme.qtPlatformTheme = config.my.darkTheme.qtPlatformTheme;
            my.darkTheme.qtStyle = config.my.darkTheme.qtStyle;
          }
        ];
      };
    };

  flake.modules.homeManager.dark-theme =
    { pkgs, lib, config, ... }:
    {
      options.my.darkTheme = {
        gtkThemeName = lib.mkOption {
          type = lib.types.str;
          default = "Adwaita-dark";
          description = "GTK theme to use (must be a dark variant).";
        };

        gtkThemePackage = lib.mkOption {
          type = lib.types.package;
          default = pkgs.gnome-themes-extra;
          description = "Package providing the GTK theme (for GTK 2 support).";
        };

        qtPlatformTheme = lib.mkOption {
          type = lib.types.str;
          default = "kde";
          description = "Qt platform theme (QT_QPA_PLATFORMTHEME), for KDE fonts/icons/dialogs integration.";
        };

        qtStyle = lib.mkOption {
          type = lib.types.str;
          default = "adwaita-dark";
          description = "Qt widget style (QT_STYLE_OVERRIDE); this carries the dark color scheme.";
        };
      };

      config = {
        # GTK: dark theme + "prefer dark" color scheme. `enable` uses mkDefault
        # so it coexists with other aspects (e.g. niri) that already set
        # `gtk.enable = true`.
        gtk = {
          enable = lib.mkDefault true;
          gtk2.force = true; # declarative owner; overwrite any stale ~/.gtkrc-2.0 left by e.g. kde-gtk-config
          theme = {
            name = config.my.darkTheme.gtkThemeName;
            package = config.my.darkTheme.gtkThemePackage;
          };
          colorScheme = "dark";
          # Explicitly keep the dark theme on GTK 4 too (with home.stateVersion
          # < 26.05 this is the legacy default, but stating it silences the
          # stateVersion warning and documents the intent).
          gtk4.theme = config.gtk.theme;
        };

        # GTK 4 / libadwaita reads the color-scheme setting via the Settings
        # portal, so mirror it in gsettings/dconf as well.
        dconf = {
          enable = true;
          settings."org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            gtk-theme = config.my.darkTheme.gtkThemeName;
          };
        };

        # Qt: the `adwaita-dark` style makes widgets dark purely from Nix
        # (independent of Plasma's color scheme), while the `kde` platform
        # theme keeps KDE fonts, icons and file dialogs under Niri too.
        qt = {
          enable = true;
          platformTheme.name = config.my.darkTheme.qtPlatformTheme;
          style.name = config.my.darkTheme.qtStyle;
        };
      };
    };
}
