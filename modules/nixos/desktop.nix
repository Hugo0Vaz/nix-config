{ pkgs, ... }: {
  services.xserver.enable = true;

  # Plasma config
  # services.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;

  # Gnome config
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  # programs.hyprland.enable = true;
  # services.hypridle.enable = true;
  # programs.hyprlock.enable = true;

  xdg.portal.enable = true;

  environment.systemPackages = with pkgs; [
    vscode
    teams-for-linux
    libreoffice
    calibre
    gimp
    inkscape
    gource
    ffmpeg
    # whatsapp-for-linux
    nyxt
    # networkmanager-openvpn
    # tangram
  ];

  nixpkgs.config.allowUnsupportedSystem = true;

  fonts.packages = with pkgs; [ nerd-fonts.fira-code ];

  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };
}
