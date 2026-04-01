{
  flake.modules.nixos.openssh =
    {
      services.openssh = {
        enable = true;
        openFirewall = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = true;
        };
      };
    };
}
