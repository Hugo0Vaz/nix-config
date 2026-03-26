{ pkgs, ... }: {

  home.packages = with pkgs; [
    neovim
    ripgrep
    fd
    tree-sitter
    nodejs_20
    gcc
  ];

  home.file.".config/nvim" = {
    source = ./config;
  };

  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };
}
