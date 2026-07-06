{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    let
      # Workaround for https://github.com/NixOS/nixpkgs/issues/528746
      # pcloud's sanitize_runtime_environment strips LD_LIBRARY_PATH to
      # only ${SCRIPT_DIR}/resources, but electron dlopen()s runtime libs
      # that live outside the bundled app dir.
      # Symlink them into resources/ so they are found via the sanitized
      # LD_LIBRARY_PATH.
      pcloud-fixed = pkgs.pcloud.overrideAttrs (prev: {
        buildInputs = (prev.buildInputs or [ ]) ++ [
          pkgs.libglvnd
          pkgs.libappindicator-gtk3
        ];
        installPhase =
          let
            libdir = "${pkgs.libglvnd}/lib";
            appindicator-libdir = "${pkgs.libappindicator-gtk3}/lib";
          in
          prev.installPhase + ''
            # Provide libglvnd's EGL/GLESv2 so electron can dlopen() them
            ln -sf ${libdir}/libEGL.so.1 $out/app/resources/libEGL.so.1
            ln -sf ${libdir}/libEGL.so $out/app/resources/libEGL.so
            ln -sf ${libdir}/libGLESv2.so.2 $out/app/resources/libGLESv2.so.2
            ln -sf ${libdir}/libGLESv2.so $out/app/resources/libGLESv2.so
            # libGLdispatch is a runtime dependency of libEGL/libGLESv2
            ln -sf ${libdir}/libGLdispatch.so.0 $out/app/resources/libGLdispatch.so.0
            ln -sf ${libdir}/libGLdispatch.so $out/app/resources/libGLdispatch.so

            # libappindicator3 enables StatusNotifierItem (SNI) DBus
            # tray icons on Wayland.  Without it electron falls back to
            # XEmbed which is unsupported by DMS (Wayland-only shell).
            ln -sf ${appindicator-libdir}/libappindicator3.so.1 $out/app/resources/libappindicator3.so.1
            ln -sf ${appindicator-libdir}/libappindicator3.so $out/app/resources/libappindicator3.so
          '';
      });
    in
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
          pcloud-fixed
          dbeaver-bin
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
