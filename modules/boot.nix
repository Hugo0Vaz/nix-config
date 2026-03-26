{
  flake.modules.nixos.boot =
    { pkgs, ... }:
    {
      boot.loader.systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 5;
      };

      boot.loader.efi.canTouchEfiVariables = true;

      boot.plymouth.enable = true;
      boot.initrd.systemd.enable = true;

      boot.kernelParams = [ "quiet" "splash" ];

      environment.systemPackages = with pkgs; [
        plymouth
      ];
    };
}
