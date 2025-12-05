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
      services.xserver.enable = true;
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

      fonts.packages = with pkgs; [ nerd-fonts.fira-code ];

      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };
    })

    (mkIf (config.monolitoSystem.desktop.enable == "plasma") {
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;
    })

    (mkIf (config.monolitoSystem.desktop.enable == "gnome") {
      services.desktopManager.gnome.enable = true;
      services.displayManager.gdm.enable = true;
    })

    (mkIf (config.monolitoSystem.desktop.enable == "hyprland") {
      programs.hyprland.enable = true;
      services.hypridle.enable = true;
      programs.hyprlock.enable = true;
    })
  ];
}
