{ pkgs, config, ... }:
let
  # Function that converts a relative string path to an absolute path
  # Usage: toAbsolutePath "relative/path" or toAbsolutePath "./relative/path"
  # Note: Must use STRING paths, not Nix path literals (no ./ prefix without quotes)
  toAbsolutePath = relativePath: 
    let
      # Get the absolute path of the directory containing this file
      thisDir = toString ./.;
      # Remove leading ./ if present
      cleanPath = 
        if builtins.substring 0 2 relativePath == "./"
        then builtins.substring 2 (builtins.stringLength relativePath) relativePath
        else relativePath;
    in
      "${thisDir}/${cleanPath}";
in
{
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


  # home.file."teste.txt" = { source = config.lib.file.mkOutOfStoreSymlink (toString ./teste.txt); };
  # home.file."teste.txt" = { source = config.lib.file.mkOutOfStoreSymlink "/home/hugomvs/Projetos/nix-config/modules/home-manager/cli/teste.txt" ; };
  home.file."teste.txt" = { source = config.lib.file.mkOutOfStoreSymlink (toAbsolutePath "./teste.txt"); };

  imports = [ ./neovim.nix ./tmux.nix ./git.nix ./ai.nix ];
}
