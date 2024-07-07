{ config, pkgs, inputs, ... }:

{

  home.username = "hugomvs";
  home.homeDirectory = "/home/hugomvs";

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    figlet
    dbeaver-bin
    jetbrains.idea-community-bin
    tree
    google-chrome
    obsidian
    neovim
    wezterm
    gcc
    go
    php
    lua
    nodejs
    python3
    kotlin
    openjdk
    php83Packages.composer
    zip
    unzip
    lua-language-server
    zsh
    fish
    oh-my-zsh
    fzf
    fzf-zsh
    nixfmt-classic
    nil
    vscodium
    rclone
    alacritty
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/hugomvs/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  #   imports = [ ./cli.nix ];
}
