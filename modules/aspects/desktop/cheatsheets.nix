{
  flake.modules.nixos.cheatsheets =
    { inputs, ... }:
    {
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.cheatsheets
      ];
    };

  flake.modules.homeManager.cheatsheets =
    { pkgs, config, ... }:
    {
      home.packages = [
        (import ../../_scripts/cheatsheet.nix { inherit pkgs; })
      ];

      # Live symlink into the repo: edit the .md files, no rebuild needed.
      home.file.".local/share/cheatsheets".source =
        config.lib.file.mkOutOfStoreSymlink /home/hugomvs/Projetos/nix-config/modules/dotfiles/cheatsheets;
    };
}
