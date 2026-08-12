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
          # bitwarden-desktop
          remmina
          samba
          meld
          darktable
          proton-vpn
          dbeaver-bin
          scribus
          cups-bjnp
          cups
          gparted
        ] ++ [ pkgs.libxcb-cursor pkgs.qt6.qtwayland ];

      services.gvfs.enable = true;
      services.dbus.enable = true;
      services.gnome.gnome-keyring.enable = true;

      services.printing = {
        enable = true;
        drivers = [ pkgs.cups-filters pkgs.cnijfilter2 ];
      };
      services.ipp-usb.enable = true;

      services.avahi = {
        enable = true;
        openFirewall = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          addresses = true;
        };
      };

      environment.variables.QT_QPA_PLATFORM = "wayland";

    };
}
