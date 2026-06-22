{
  flake.modules.nixos.mininvim =
    { inputs, ... }:
    {
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.mininvim
      ];
    };

  flake.modules.homeManager.mininvim =
    { config, pkgs, ... }:
    {
      home.packages = with pkgs; [
        neovim
        ripgrep
        fd
        tree-sitter
        nodejs_22
        gcc
        nixd
        lua-language-server
      ];

      # home.file.".config/12nvim" = {
      #   source = ../dotfiles/nvim;
      # };

      home.file.".config/12nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink "/home/hugomvs/Projetos/nix-config/modules/dotfiles/12nvim";
      };

      home.shellAliases = {
        "minvim" = "NVIM_APPNAME=12nvim nvim";
      };
    };
}
