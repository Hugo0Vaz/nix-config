{
  flake.modules.nixos.browsers =
    { pkgs, ... }:
    {
      environment.systemPackages =
        with pkgs;
        [
          google-chrome
          firefox
          vivaldi
        ];
    };
}
