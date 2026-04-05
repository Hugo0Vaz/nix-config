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

      home-manager.sharedModules = [
        inputs.self.modules.homeManager.sops
      ];

      sops = {
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        defaultSopsFile = inputs.self.outPath + "/secrets/${config.networking.hostName}.yaml";
      };
    };

  flake.modules.homeManager.sops =
    { inputs, pkgs, ... }:
    {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
      ];

      home.packages = with pkgs; [
        sops
        age
        ssh-to-age
      ];
    };
}
