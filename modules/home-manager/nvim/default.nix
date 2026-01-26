{ pkgs, config, flakeRoot, ... }: {

  home.packages = with pkgs; [
    neovim
    ripgrep
    fd
    tree-sitter
    nodejs_20
    gcc
  ];

  home.file.".config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${flakeRoot}/modules/home-manager/nvim/config";
  };

  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };
}

