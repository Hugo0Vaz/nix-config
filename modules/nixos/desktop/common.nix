{ lib, pkgs, config, ... }:
with lib;

mkIf (config.monolitoSystem.desktop.enable != "none") {
  services.xserver.enable = true;
  xdg.portal.enable = true;
  nixpkgs.config.allowUnsupportedSystem = true;
 
  environment.systemPackages = with pkgs; [
    teams-for-linux
    networkmanagerapplet
    waybar
    libreoffice
    calibre
    vlc
    gimp
    inkscape
    vivaldi
    google-chrome
    firefox
    darktable
    chatbox
    localsend
    vim
    git
    wget
    curl
    nix-output-monitor
    gnupg
    pinentry-gnome3
    deskflow
    drawio
    dunst
    obsidian
    obs-studio
    thunderbird
    dbeaver-bin
    geany
    kdePackages.okular
    pinta
    speedcrunch
    jetbrains.idea-oss
    podman
    podman-compose
    winboat
    filezilla
    kitty
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    jetbrains-mono
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  security.rtkit.enable = true;

  services.udisks2.enable = true;
}
