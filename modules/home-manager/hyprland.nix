{ config, lib, pkgs, ... }:

with lib;

{
  options.hyprland = {
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

  config = {
    home.packages = with pkgs; [
      ydotool
      wofi
      nautilus
      grim
      slurp
      wl-clipboard
      hyprpaper
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
          "~/.config/wallpapers/nix-wallpaper.png"
        ];
        wallpaper = [
          ",~/.config/wallpapers/nix-wallpaper.png"
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
