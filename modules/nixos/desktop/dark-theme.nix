{ pkgs, config, lib, ... }:
{
  config = lib.mkIf (config.monolitoSystem.desktop.enable != "none") {
    # Enable dconf for GTK settings
    programs.dconf.enable = true;
    
    # System-wide dark theme preference for GTK apps
    environment.etc."xdg/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=1
    '';
    
    environment.etc."xdg/gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=1
    '';
  };
}
