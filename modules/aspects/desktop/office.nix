{
  flake.modules.nixos.office =
    { pkgs, ... }:
    {
      environment.systemPackages =
        with pkgs;
        [
          (pkgs.symlinkJoin {
            # Run natively on Wayland: under XWayland (xwayland-satellite) the
            # FileChooser portal gets an X11 parent handle and Nautilus (the
            # GNOME portal's file chooser backend) segfaults in
            # gxdp_wayland_set_x11_parent.
            name = "teams-for-linux-wayland";
            paths = [ teams-for-linux ];
            postBuild = ''
              rm "$out/share/applications/teams-for-linux.desktop"
              mkdir -p "$out/share/applications"
              ln -s ${pkgs.makeDesktopItem {
                name = "teams-for-linux";
                exec = "teams-for-linux --ozone-platform=wayland --enable-features=WaylandWindowDecorations %U";
                icon = "teams-for-linux";
                desktopName = "Microsoft Teams for Linux";
                comment = "Unofficial Microsoft Teams client for Linux";
                categories = [ "Network" "InstantMessaging" "Chat" ];
                mimeTypes = [ "x-scheme-handler/msteams" ];
              }}/share/applications/teams-for-linux.desktop "$out/share/applications/teams-for-linux.desktop"
            '';
          })
          libreoffice
          obsidian
          calibre
          kdePackages.okular
          speedcrunch
          drawio
          obs-studio
        ];

      networking.firewall.allowedTCPPorts = [ 9090 ];
    };
}
