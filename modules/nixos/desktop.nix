{ pkgs, ... }: {
  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  programs.hyprland.enable = true;
  services.hypridle.enable = true;
  programs.hyprlock.enable = true;

  xdg.portal.enable = true;

  environment.systemPackages = with pkgs; [
    vscode
    teams-for-linux
    libreoffice
    calibre
  ];

  nixpkgs.config.allowUnsupportedSystem = true;

  fonts.packages = with pkgs; [
    nerdfonts
  ];

  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };
}
