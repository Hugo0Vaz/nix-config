{
  flake.modules.nixos.openssh =
    {
      services.openssh = {
        enable = true;
        openFirewall = true;
        settings = {
          PermitRootLogin = true;
          PasswordAuthentication = true;
        };
      };
    };
}
