{
  flake.modules.nixos.openssh =
    { config, ... }:
    {
      services.openssh = {
        enable = true;
        openFirewall = true;

        settings = {
          PermitRootLogin = "prohibit-password";
          PubkeyAuthentication = true;
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          AuthenticationMethods = "publickey";
        };
      };

      users.users.root.openssh.authorizedKeys.keys =
        config.users.users.admin.openssh.authorizedKeys.keys;
    };
}
