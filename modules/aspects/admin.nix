{
  flake.modules.nixos.admin =
    { config
    , inputs
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
        openssh.authorizedKeys.keys = config.my.ssh.authorizedKeys;
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
