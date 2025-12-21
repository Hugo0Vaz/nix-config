{ config, self, ... }: {

  home.packages = with pkgs; [
    tree-sitter
    ripgrep
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

