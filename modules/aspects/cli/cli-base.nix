{
  flake.modules.nixos.cli-base =
    { inputs, pkgs, ... }:
    {
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.cli-base
      ];
    };

  flake.modules.homeManager.cli-base =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        file
        vim
        wget
        zip
        unzip
        tree
        ripgrep
        fd
        fzf
        zoxide
        inetutils
        sysstat
        dig
        mtr
      ];

      programs.eza = {
        enable = true;
        enableFishIntegration = true;
        enableBashIntegration = true;
      };
    };
}
