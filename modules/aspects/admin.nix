{
  flake.modules.nixos.admin =
    { inputs
    , lib
    , pkgs
    , ...
    }:
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

      home-manager = {
        useGlobalPkgs = lib.mkDefault true;
        useUserPackages = lib.mkDefault true;
        extraSpecialArgs = lib.mkDefault { inherit inputs; };

        users.admin =
          { ... }:
          {
            imports = [ inputs.self.modules.homeManager.cli-tools ];

            home.username = lib.mkDefault "admin";
            home.homeDirectory = lib.mkDefault "/home/admin";
            home.stateVersion = lib.mkDefault "24.05";
            programs.home-manager.enable = lib.mkDefault true;
          };
      };
    };
}
