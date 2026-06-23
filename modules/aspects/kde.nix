{
  flake.modules.nixos.kde =
    { inputs, pkgs, ... }:
    {
      services.desktopManager.plasma6.enable = true;

      # Qt theming: use KDE platform integration + Breeze widget style.
      # The actual light/dark toggle is controlled by ~/.config/kdeglobals
      # (set via the home-manager module below).
      qt.platformTheme = "kde";
      qt.style = "breeze";

      # Ensure the KDE platform integration package is available so Qt
      # apps can resolve the KDE theme engine at runtime.
      environment.systemPackages = [ pkgs.kdePackages.plasma-integration ];

      # Exclude KDE's default packages that conflict or overlap with
      # packages already managed by other aspects.
      environment.plasma6.excludePackages = with pkgs.kdePackages; [
        elisa
        konsole
        okular
      ];

      home-manager.sharedModules = [
        inputs.self.modules.homeManager.kde
      ];
    };

  flake.modules.homeManager.kde =
    { ... }:
    {
      xdg.configFile."kdeglobals".text = ''
        [General]
        ColorScheme=BreezeDark
      '';
    };
}
