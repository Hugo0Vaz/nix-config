{
  flake.modules.nixos.hugo =
    { inputs, pkgs, config, ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];

      users.users.hugomvs = {
        isNormalUser = true;
        description = "Hugo Martins Vaz Silva";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.fish;
        initialPassword = "123456789";
      };

      users.users.hugomvs.openssh.authorizedKeys.keys = config.my.ssh.authorizedKeys;
      environment.shells = [ pkgs.fish ];

      programs.fish.enable = true;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bkp";

        extraSpecialArgs = { inherit inputs; };

        # Ensure HM is actually managing hugomvs on all NixOS hosts
        # that import this module. Host-specific HM modules can still
        # override these via non-default assignments.
        users.hugomvs =
          { lib, ... }:
          {
            home.username = lib.mkDefault "hugomvs";
            home.homeDirectory = lib.mkDefault "/home/hugomvs";
            home.stateVersion = lib.mkDefault "24.05";
            programs.home-manager.enable = lib.mkDefault true;
          };

        sharedModules = [
          inputs.self.modules.homeManager.hugo
        ];
      };
    };

  flake.modules.homeManager.hugo = {
    programs.git = {
      enable = true;
      settings = {
        user.name = "Hugo0Vaz";
        user.email = "hugomartinsvaz@gmail.com";
      };
    };

    programs.git.signing.format = null;

    home.file.".face" = {
      source = ../assets/profile.jpg;
    };
  };
}
