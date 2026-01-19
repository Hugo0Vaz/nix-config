{ config, lib, pkgs, ... }:
with lib;
{
  options.monolitoSystem.hyprland = {
    uiSize = mkOption {
      type = types.enum [ "default" "small" ];
      default = "default";
      description = ''
        UI size configuration for Hyprland, waybar, and wofi.
        - "default": Standard sizes for regular screens
        - "small": Compact sizes for smaller screens
      '';
    };
  };

  config = let
    screenshotToPinta = pkgs.callPackage ./monolito/screenShotToPinta.nix {};
    powerMenu = pkgs.callPackage ./monolito/powerMenu.nix {};
  in {
    home.packages = with pkgs; [
      ydotool
      wofi
      nautilus
      grim
      slurp
      wl-clipboard
      hyprpaper
      pinta
      libnotify
      screenshotToPinta
      powerMenu
      copyq
    ];

    home.pointerCursor = {
      package = pkgs.kdePackages.breeze;
      name = "breeze_cursors";
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    home.file.".config/hypr/hyprland.conf" = {
      source = ./hyprland/hyprland.conf;
    };

    services.hyprpaper = {
      enable = true;
      settings = {
        preload = [
          "${config.home.homeDirectory}/.config/wallpapers/nix-wallpaper.png"
        ];
        wallpaper = [
          "HDMI-A-1,${config.home.homeDirectory}/.config/wallpapers/nix-wallpaper.png"
        ];
      };
    };

    home.file.".config/wallpapers/nix-wallpaper.png" = {
      source = ../../assets/nix-wallpaper.png;
    };

    home.file.".config/hypr/hyprlock.conf" = {
      source = ./hyprland/hyprlock.conf;
    };

    home.file.".config/dunst/dunstrc" = {
      source = ./dunst/dunstrc;
    };
  };
}
