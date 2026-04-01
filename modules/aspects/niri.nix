{
  flake.modules.nixos.niri =
    { inputs, pkgs, ... }:
    {
      programs.niri.enable = true;

      services.xserver.enable = true;
      services.xserver.displayManager.gdm.enable = true;
      services.xserver.displayManager.gdm.wayland = true;

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

  flake.modules.homeManager.niri =
    { pkgs, ... }:
    {
      home.file.".config/niri/config.kdl" = {
        source = ../dotfiles/niri/default-config.kdl;
      };
    };
}
