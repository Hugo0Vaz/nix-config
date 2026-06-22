{
  flake.modules.nixos.kde =
    { pkgs, ... }:
    {
      services.desktopManager.plasma6.enable = true;

      # Exclude KDE's default packages that conflict or overlap with
      # packages already managed by other aspects.
      environment.plasma6.excludePackages = with pkgs.kdePackages; [
        elisa
        kate
        konsole
        okular
      ];
    };
}
