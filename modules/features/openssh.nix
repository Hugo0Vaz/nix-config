{
  flake.modules.nixos.basicPackages =
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
