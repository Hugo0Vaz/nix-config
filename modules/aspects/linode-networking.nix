{
  flake.modules.nixos.linode-networking =
    { pkgs, ... }:
    {
      networking.useDHCP = false;
      networking.networkmanager.enable = true;
      networking.interfaces.eth0.useDHCP = true;
      networking.usePredictableInterfaceNames = false;
    };
}
