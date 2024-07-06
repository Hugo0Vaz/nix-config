{ config, pkgs, options, inputs, ... }:

{
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-workstation";
  networking.networkmanager.enable = true;
  networking.timeServers = options.networking.timeServers.default
    ++ [ "a.ntp.br" ];

  time.timeZone = "America/Sao_Paulo";

  services.geoclue2.enable = true;
  services.ntp.enable = true;
  services.localtimed.enable = true;
  services.timesyncd.enable = true;

  i18n.defaultLocale = "pt_BR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  console.keyMap = "br-abnt2";

  services.printing.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.hugomvs = {
    isNormalUser = true;
    description = "Hugo Martins Vaz Silva";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ kdePackages.kate ];
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    google-chrome
    obsidian
    neovim
    wezterm
    git
    stow
    gcc
    go
    php
    lua
    nodejs
    python3
    kotlin
    openjdk
    php83Packages.composer
    vscode
    zip
    unzip
    lua-language-server
    zsh
    fish
    oh-my-zsh
    fzf
    fzf-zsh
    nixfmt-classic
    vscodium
    rclone
  ];

  imports = [ ./hardware-configuration.nix ./../../modules/nixos/nvidia.nix ];
}
