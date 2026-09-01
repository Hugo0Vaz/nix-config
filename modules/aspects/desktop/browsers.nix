{
  flake.modules.nixos.browsers =
    { pkgs, inputs, ... }:
    let
      zen-browser = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      environment.systemPackages =
        with pkgs;
        [
          firefoxpwa
          google-chrome
          firefox
          vivaldi
          zen-browser
        ];

      programs.firefox = {
        enable = true;
        package = pkgs.firefox;
        nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
      };
    };
}
