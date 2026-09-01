{
  flake.modules.nixos.ssh-authorized-keys =
    { lib, ... }:
    {
      options.my.ssh.authorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID6yWX3IBaW8JOj/NBygnPOrIqrFMcoDuAQ1oGYKueUa hugomvs@nixos-workstation"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQNQIRKgJxqQjk9HyJl5hWiQmOc0QRhDWNUARZ8CLF3 hugomvs@nixos-workstation"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICodiRq/5jSy1HfpNohFqF0TYmYxMYexx8+6gs9wtqlI hugomvs@nixos-kot225"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILZiL6CSlxY/RpqK+nLpmQlYiaK63CUyBWvZKFEdHA+B u0_a388@localhost" # chave de ssh do s26
        ];
        description = "SSH authorized_keys shared across hosts.";
      };
    };
}
