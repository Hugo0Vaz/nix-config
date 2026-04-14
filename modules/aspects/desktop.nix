{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      environment.systemPackages =
        with pkgs;
        [
          nautilus
          localsend
          inkscape
          gimp2
          pinta
          copyq
          bitwarden-desktop
        ];
    };
}
