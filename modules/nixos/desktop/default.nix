{ lib, pkgs, config, ... }:
with lib;
{
  options.monolitoSystem.desktop = {
    enable = lib.mkOption {
      type = lib.types.enum [ "plasma" "gnome" "hyprland" "none" ];
      default = "none";
      description = "Which desktop enviroment to use";
    };
  };

  config =  mkMerge [
    (mkIf (config.monolitoSystem.desktop.enable != "none") {

      # COMMON FOR ALL DESKTOP SESSIONS
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
        thunderbird
        dbeaver-bin
      ];

      fonts.packages = with pkgs; [
        nerd-fonts.fira-code
        jetbrains-mono
      ];

      programs.gnupg.agent = {
        pinentryPackage = pkgs.pinentry-gnome3;
        enableSSHSupport = true;
        enable = true;
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

    })

    (mkIf (config.monolitoSystem.desktop.enable == "plasma") {
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;
    })

    (mkIf (config.monolitoSystem.desktop.enable == "gnome") {
      services.desktopManager.gnome.enable = true;
      services.displayManager.gdm.enable = true;

      # hack for gnome shell glitch
      environment.variables = {
        GSK_RENDERER = "ngl";
      };
    })

    (mkIf (config.monolitoSystem.desktop.enable == "hyprland") {
      programs.hyprland.enable = true;
      services.hypridle.enable = true;
      # programs.hyprlock.enable = true;
      services.displayManager.sddm.enable = true;
    })
  ];
}
