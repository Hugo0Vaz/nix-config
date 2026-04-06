{
  flake.modules.nixos.sops =
    { config
    , inputs
    , ...
    }:
    {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];

      sops = {
        age.keyFile = "/var/lib/sops-nix/key.txt";

        defaultSopsFile = inputs.self.outPath + "/secrets/secrets.yaml";

        validateSopsFiles = true;
      };
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
