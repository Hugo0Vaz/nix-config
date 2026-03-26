{ lib, config, ... }:
with lib;
mkIf (config.monolitoSystem.desktop.enable == "plasma") {
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
}
