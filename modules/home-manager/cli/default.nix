{ pkgs, config, ... }: {
  home.packages = with pkgs; [
    figlet
    tree
    zip
    unzip
    fzf
    rclone
    fd
    ripgrep
    lazygit
    nix-direnv
    zoxide
    file
    aider-chat
    gh
    pass
    go-blueprint
    uv
    tldr
    fido2-manage
    dig
    imagemagick
    btop
    fastfetch
  ];

  programs.eza.enable = true;


  home.file."teste.txt" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/hugomvs/Projetos/nix-config/modules/home-manager/cli/teste.txt";
  };

  imports = [ ./neovim.nix ./tmux.nix ./git.nix ./ai.nix ];
}
