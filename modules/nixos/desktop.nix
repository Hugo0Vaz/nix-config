{ config, ... }: {
  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  programs.hyprland.enable = true;
  services.hypridle.enable = true;
  programs.hyprlock.enable = true;

  xdg.portal.enable = true;

  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };
}
