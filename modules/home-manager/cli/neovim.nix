{ ... }: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  home.file.".config/nvim" = {
    source = ./../../../dotfiles/nvim/.config/nvim;
    recursive = true;
    executable = true;
  };
}
