{
  flake.modules.nixos.niri =
    { inputs, pkgs, ... }:
    {
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
        # inputs.noctalia.homeModules.default
        inputs.self.modules.homeManager.niri
      ];
    };

  flake.modules.nixos.niri-workstation =
    { inputs, pkgs, ... }:
    {
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
        # inputs.noctalia.homeModules.default
        inputs.self.modules.homeManager.niri-workstation
      ];
    };

  flake.modules.homeManager.niri =
    { pkgs, ... }:
    {
      home.file.".config/niri/config.kdl" = {
        source = ../dotfiles/niri/default-config.kdl;
      };

      home.file.".config/noctalia/settings.json" = {
        source = ../dotfiles/noctalia/noctalia.json;
      };
    };

  flake.modules.homeManager.niri-workstation =
    { pkgs, ... }:
    {
      home.file.".config/niri/config.kdl" = {
        source = ../dotfiles/niri/default-config.kdl;
      };

      home.file.".config/noctalia/settings.json" = {
        source = ../dotfiles/noctalia/noctalia-workstation.json;
      };
    };

  flake.modules.nixos.niri-kot225 =
    { inputs, pkgs, ... }:
    {
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
        inputs.self.modules.homeManager.niri-kot225
      ];
    };

  flake.modules.homeManager.niri-kot225 =
    { pkgs, ... }:
    {
      home.file.".config/niri/config.kdl" = {
        source = ../dotfiles/niri/kot225-config.kdl;
      };

      home.file.".config/noctalia/settings.json" = {
        source = ../dotfiles/noctalia/noctalia-kot225.json;
      };
    };
}
