{
  flake.modules.nixos.niri =
    { inputs, pkgs, lib, config, ... }:
    {
      options.my.niri = {
        monitorsConfig = lib.mkOption {
          type = lib.types.path;
          default = ../dotfiles/niri/monitors-default.kdl;
          description = "Path to the monitors KDL config file (monitors-default.kdl, monitors-kot225.kdl, etc.).";
        };

        noctaliaConfig = lib.mkOption {
          type = lib.types.path;
          default = ../dotfiles/noctalia/noctalia.json;
          description = "Path to the noctalia settings JSON file.";
        };

        cursorName = lib.mkOption {
          type = lib.types.str;
          default = "breeze_cursors";
          description = "Name of the cursor theme to use (e.g. breeze_cursors or Breeze_Snow).";
        };

        cursorSize = lib.mkOption {
          type = lib.types.int;
          default = 24;
          description = "Size of the cursor in pixels.";
        };
      };

      config = {
        programs.niri.enable = true;

        services.xserver.enable = true;
        services.displayManager.gdm.enable = true;
        services.displayManager.gdm.wayland = true;

        services.gnome.gnome-keyring.enable = true;
        security.polkit.enable = true;

        xdg.portal.enable = true;
        xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];

        networking.networkmanager.enable = true;
        hardware.bluetooth.enable = true;
        services.power-profiles-daemon.enable = true;
        services.upower.enable = true;

        environment.systemPackages = with pkgs; [
          polkit_gnome
          noctalia-shell
        ];

        home-manager.sharedModules = [
          inputs.self.modules.homeManager.niri
          {
            my.niri.monitorsConfig = config.my.niri.monitorsConfig;
            my.niri.noctaliaConfig = config.my.niri.noctaliaConfig;
            my.niri.cursorName = config.my.niri.cursorName;
            my.niri.cursorSize = config.my.niri.cursorSize;
          }
        ];
      };
    };

  flake.modules.homeManager.niri =
    { pkgs, lib, config, ... }:
    {
      options.my.niri = {
        monitorsConfig = lib.mkOption {
          type = lib.types.path;
          default = ../dotfiles/niri/monitors-default.kdl;
          description = "Path to the monitors KDL config file.";
        };

        noctaliaConfig = lib.mkOption {
          type = lib.types.path;
          default = ../dotfiles/noctalia/noctalia.json;
          description = "Path to the noctalia settings JSON file.";
        };

        cursorName = lib.mkOption {
          type = lib.types.str;
          default = "breeze_cursors";
          description = "Name of the cursor theme to use.";
        };

        cursorSize = lib.mkOption {
          type = lib.types.int;
          default = 24;
          description = "Size of the cursor in pixels.";
        };
      };

      config = {
        home.pointerCursor = {
          gtk.enable = true;
          x11.enable = true;
          package = pkgs.kdePackages.breeze;
          name = config.my.niri.cursorName;
          size = config.my.niri.cursorSize;
        };

        home.file.".config/niri/config.kdl".source =
          pkgs.writeText "niri-config.kdl" ''
            include "${../dotfiles/niri/main.kdl}"
            include "${config.my.niri.monitorsConfig}"
          '';

        home.file.".config/noctalia/settings.json".source =
          config.my.niri.noctaliaConfig;
      };
    };
}
