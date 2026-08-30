{
  flake.modules.nixos.office =
    { pkgs, ... }:
    {
      environment.systemPackages =
        with pkgs;
        [
          teams-for-linux
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
