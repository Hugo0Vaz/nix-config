{ config, lib, ... }:
with lib;
{
  options.monolitoSystem.desktop = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Option to enable desktop enviroments";
    };

    type = mkOption {
      type = types.enum [ "plasma" "gnome" "hyprland" ];
      default = "hyprland";
      description = "Which desktop enviroment to use";
    };
  };

  config = lib.mkIf config.monolitoSystem.desktop.enable (lib.mkMerge [
    {
      services.xserver.enable = true;
      xdg.portal.enable = true;
    }

    (lib.mkIf (config.monolitoSystem.desktop.type == "plasma") {
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;
    })

    (lib.mkIf (config.monolitoSystem.desktop.type == "gnome") {
      services.desktopManager.gnome.enable = true;
      services.displayManager.gdm.enable = true;
    })

    (lib.mkIf (config.monolitoSystem.desktop.type == "hyprland") {
      programs.hyprland.enable = true;
      services.hypridle.enable = true;
      programs.hyprlock.enable = true;
    })

  ]);
}
