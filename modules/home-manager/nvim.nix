{ pkgs, config, self, ... }: {

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
    recursive = true;
    source = config.lib.file.mkOutOfStoreSymlink "${self}/modules/home-manager/nvim/";
  };
}

