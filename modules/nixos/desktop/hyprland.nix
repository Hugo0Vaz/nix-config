{ lib, pkgs, config, ... }:
with lib;

mkIf (config.monolitoSystem.desktop.enable == "hyprland") {
  programs.hyprland.enable = true;
  services.hypridle.enable = true;

  networking.networkmanager.enable = true;
  services.gnome.gnome-keyring.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${getExe pkgs.cage} -s -- ${getExe pkgs.regreet}";
      user = "greeter";
    };
  };

  programs.regreet = {
    enable = true;
    settings = {
      background = {
        path = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
        fit = "Cover";
      };
      GTK.application_prefer_dark_theme = mkDefault true;
    };
  };

  environment.etc."greetd/environments".text = ''
    Hyprland
  '';

  environment.systemPackages = with pkgs; [
    cage
    regreet
  ];
}

