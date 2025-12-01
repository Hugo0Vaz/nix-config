{ config, lib, pkgs, options, ... }:
with lib;
{
  options.monolitoSystem.desktop = {
    enable = lib.mkOption {
      type = lib.types.enum [ "plasma" "gnome" "hyprland" "none" ];
      default = "none";
      description = "Which desktop enviroment to use";
    };
  };

  config = {
    services.xserver.enable = true;

  # Plasma config
  # services.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;

  # Gnome config
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # programs.hyprland.enable = true;
  # services.hypridle.enable = true;
  # programs.hyprlock.enable = true;

  programs.nix-ld.enable = true;
  xdg.portal.enable = true;

  nixpkgs.config.allowUnsupportedSystem = true;

  environment.systemPackages = with pkgs; [
    vscode
    jetbrains-mono
    teams-for-linux
    libreoffice
    calibre
    gimp
    inkscape
    gource
    ffmpeg
    nyxt
    vivaldi
    openvpn3
    darktable
    pomodoro-gtk
    sillytavern
    chatbox
  ];


  # FONTS ######################################################################
  fonts.packages = with pkgs; [ nerd-fonts.fira-code ];

  # AUDIO ######################################################################
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  };

}
