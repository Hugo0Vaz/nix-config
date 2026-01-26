{ config, lib, pkgs, flakeRoot, ... }:
with lib;
{
  options.monolitoSystem.hyprland = {
    monitors = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        List of monitor names to apply wallpaper to.
        Must be set per-host. Use 'hyprctl monitors' to see available monitor names.
      '';
      example = [ "HDMI-A-1" "eDP-1" ];
    };
  };

  config = {
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
      copyq
      numlockx
    ];

    services.hyprpaper = {
      enable = true;
      settings = let
        wallpaperPath = "${config.home.homeDirectory}/.config/wallpapers/nix-wallpaper.png";
        monitors = config.monolitoSystem.hyprland.monitors;
      in {
        preload = [ wallpaperPath ];

        wallpaper = map (monitor: {
          monitor  = monitor;
          path     = wallpaperPath;
          fit_mode = "cover"; # optional, explicit default
        }) monitors;
      };
    };

    home.file.".config/hypr/hyprland.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink "${flakeRoot}/modules/home-manager/hyprland/hyprland.conf";
    };

    home.file.".config/wallpapers/nix-wallpaper.png" = {
      source = ../../../assets/nix-wallpaper.png;
    };

    home.file.".config/hypr/hyprlock.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink "${flakeRoot}/modules/home-manager/hyprland/hyprlock.conf";
    };

    home.file.".config/dunst/dunstrc" = {
      source = config.lib.file.mkOutOfStoreSymlink "${flakeRoot}/modules/home-manager/dunst/dunstrc";
    };
  };
}
