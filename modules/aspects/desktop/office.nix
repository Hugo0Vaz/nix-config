{
  flake.modules.nixos.office =
    { pkgs, ... }:
    {
      environment.systemPackages =
        with pkgs;
        [
          (pkgs.symlinkJoin {
            name = "teams-for-linux-x11";
            paths = [ teams-for-linux ];
            postBuild = ''
              rm "$out/share/applications/teams-for-linux.desktop"
              mkdir -p "$out/share/applications"
              ln -s ${pkgs.makeDesktopItem {
                name = "teams-for-linux";
                exec = "teams-for-linux --ozone-platform=x11 %U";
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
          apostrophe
          drawio
        ];

      networking.firewall.allowedTCPPorts = [ 9090 ];
    };
}
