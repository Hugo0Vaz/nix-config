{
  flake.modules.nixos.browsers =
    { pkgs, ... }:
    {
      environment.systemPackages =
        with pkgs;
        [
          firefoxpwa
          google-chrome
          firefox
          vivaldi
        ];

      programs.firefox = {
        enable = true;
        package = pkgs.firefox;
        nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
      };
    };
}
