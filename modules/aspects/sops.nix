{
  flake.modules.nixos.sops =
    { config
    , inputs
    , pkgs
    , ...
    }:
    {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];

      home-manager.sharedModules = [
        inputs.self.modules.homeManager.sops
      ];

      environment.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      sops = {
        age.keyFile = "/var/lib/sops-nix/key.txt";

        defaultSopsFile = inputs.self.outPath + "/secrets/secrets.yaml";

        validateSopsFiles = true;
      };

      environment.systemPackages =
        with pkgs;
        [
          sops
          age
          ssh-to-age
        ];
    };

  flake.modules.homeManager.sops =
    { config
    , inputs
    , pkgs
    , ...
    }:
    {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
      ];

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      sops = {
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

        defaultSopsFile = inputs.self.outPath + "/secrets/secrets.yaml";
      };

      home.packages = with pkgs; [
        sops
        age
        ssh-to-age
      ];
    };
}
