{ lib, config, ... }:
with lib;

mkIf (config.monolitoSystem.desktop.enable == "gnome") {
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # hack for gnome shell glitch
  environment.variables.GSK_RENDERER = "ngl";
}
