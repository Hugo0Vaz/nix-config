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
    screenshotToPinta = pkgs.writeShellScriptBin "screenshot-to-pinta" ''
      # Create Screenshots directory if it doesn't exist
      mkdir -p ~/Pictures/Screenshots

      # Generate filename with timestamp
      FILENAME=~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S.png')

      # Take screenshot based on argument
      case "$1" in
        "area")
          ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$FILENAME"
          ;;
        "full")
          ${pkgs.grim}/bin/grim "$FILENAME"
          ;;
        *)
          echo "Usage: $0 {area|full}"
          exit 1
          ;;
      esac

      # Check if screenshot was taken successfully
      if [ -f "$FILENAME" ]; then
        # Open in Pinta
        ${pkgs.pinta}/bin/pinta "$FILENAME" &
      else
        ${pkgs.libnotify}/bin/notify-send "Screenshot Failed" "Could not capture screenshot"
      fi
    '';
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
          "HDMI-A-1,~/.config/wallpapers/nix-wallpaper.png"
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
