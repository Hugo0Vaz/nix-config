{
  flake.modules.nixos.linode-networking =
    { pkgs, ... }:
    {
      networking.useDHCP = false;
      networking.networkmanager.enable = true;
      networking.nameservers = [ "1.1.1.1" "1.0.0.1" "9.9.9.9" ];
      networking.interfaces.eth0.useDHCP = true;
      networking.usePredictableInterfaceNames = false;
    };
}
