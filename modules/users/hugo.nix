{
  flake.modules.nixos.hugo =
    { inputs, pkgs }:
    {
      users.users.hugomvs = {
        isNormalUser = true;
        description = "Hugo Martins Vaz Silva";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.fish;
      };

      environment.shells = [ pkgs.fish ];

      home-manager.sharedModules = [
        inputs.self.modules.homeManager.hugo
      ];
    };

  flake.modules.homeManager.hugo = {
    programs.git = {
      enable = true;
      settings = {
        user.name = "Hugo0Vaz";
        user.email = "hugomartinsvaz@gmail.com";
      };
    };

    home.file.".face" = {
      source = ../assets/profile.jpg;
    };
  };
}
