{ pkgs, config, flakeRoot, ... }: {

  home.packages = with pkgs; [
    ripgrep
    fd
    tree-sitter
    nodejs_20
    gcc
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  home.file.".config/nvim/" = {
    source = config.lib.file.mkOutOfStoreSymlink "${flakeRoot}/modules/home-manager/nvim/config/";
  };
}

