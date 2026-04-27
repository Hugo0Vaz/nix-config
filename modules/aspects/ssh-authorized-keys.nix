{
  flake.modules.nixos.ssh-authorized-keys =
    { lib, ... }:
    {
      options.my.ssh.authorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBUinTmOEky+U/j8Dh5tUhsyWxnMgkpGsKH3uQKKGNgN hugom@kot225"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID6yWX3IBaW8JOj/NBygnPOrIqrFMcoDuAQ1oGYKueUa hugomvs@nixos-workstation"
        ];
        description = "SSH authorized_keys shared across hosts.";
      };
    };
}
