{
  flake.modules.nixos.admin =
    { pkgs, ... }:
    {
      users.users.admin = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
        description = "System Admin";
        home = "/home/admin";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBUinTmOEky+U/j8Dh5tUhsyWxnMgkpGsKH3uQKKGNgN hugom@kot225"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQNQIRKgJxqQjk9HyJl5hWiQmOc0QRhDWNUARZ8CLF3 hugomvs@nixos-workstation"
        ];
      };
    };
}
