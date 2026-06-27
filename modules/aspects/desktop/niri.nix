{
  flake.modules.nixos.niri =
    { inputs, pkgs, lib, config, ... }:
    {
      options.my.niri = {
        dmsDotfileRoot = lib.mkOption {
          type = lib.types.str;
          default = "/home/hugomvs/Projetos/nix-config/modules/dotfiles/dms";
          description = "Absolute path to the DMS (DankMaterialShell) dotfiles directory in the repo. Changes take effect immediately without rebuild (out-of-store symlink).";
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

        programs.dms-shell = {
          enable = true;
          systemd.enable = true;
        };

        # Bind DMS to niri.session so it only spawns in niri, never in KDE.
        systemd.user.services.dms = {
          wantedBy = lib.mkForce [ "niri.service" ];
          bindsTo = [ "niri.service" ];
          after = [ "niri.service" ];
        };

        services.xserver.enable = true;
        services.displayManager.sddm.enable = true;
        services.displayManager.sddm.wayland.enable = true;

        services.gnome.gnome-keyring.enable = true;
        security.polkit.enable = true;

        xdg.portal.enable = true;
        xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];

        networking.networkmanager.enable = true;
        networking.nameservers = [ "1.1.1.1" "1.0.0.1" "9.9.9.9" ];
        hardware.bluetooth.enable = true;
        services.power-profiles-daemon.enable = true;
        services.upower.enable = true;

        environment.systemPackages = with pkgs; [
          polkit_gnome
        ];

        home-manager.sharedModules = [
          inputs.self.modules.homeManager.niri
          {
            my.niri.dmsDotfileRoot = config.my.niri.dmsDotfileRoot;
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
        dmsDotfileRoot = lib.mkOption {
          type = lib.types.str;
          default = "/home/hugomvs/Projetos/nix-config/modules/dotfiles/dms";
          description = "Absolute path to the DMS (DankMaterialShell) dotfiles directory in the repo. Changes take effect immediately without rebuild (out-of-store symlink).";
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

        home.file.".config/niri/main.kdl".source = ../../dotfiles/niri/main.kdl;

        home.file.".config/niri/config.kdl".source = ../../dotfiles/niri/config.kdl;

        home.file.".config/DankMaterialShell".source =
          config.lib.file.mkOutOfStoreSymlink config.my.niri.dmsDotfileRoot;
      };
    };
}
