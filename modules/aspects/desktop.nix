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
          # gimp2
          pinta
          copyq
          bitwarden-desktop
          remmina
          samba
          chatbox
        ];

      services.gvfs.enable = true;
      services.dbus.enable = true;
      services.gnome.gnome-keyring.enable = true;

      services.avahi = {
        enable = true;
        openFirewall = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          addresses = true;
        };
      };

    };
}
