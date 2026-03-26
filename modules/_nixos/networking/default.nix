{ config, lib, ...}:
with lib;
{

  imports = [
    ./firewall.nix
    ./tailscale.nix
  ];

  options.monolitoSystem.ssh = {
    enable = lib.mkEnableOption "SSH Server";

    rootLogin = lib.mkOption {
      type = types.str;
      default = "no";
      description = "Enable root login";
    };
  };

  config = lib.mkIf config.monolitoSystem.ssh.enable {
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = config.monolitoSystem.ssh.rootLogin;
        PasswordAuthentication = true;
      };
    };
  };

}
