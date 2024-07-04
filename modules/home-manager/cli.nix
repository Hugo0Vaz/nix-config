{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      age
      aria2
      bat
      bc
      btop
      entr
      fd
      file
      ijq
      ranger
      jq
      lazydocker
      lazygit
      moreutils
      trash-cli
      unzip
      usbutils
      wget
      curl
      stow
    ];
    sessionVariables = {
      LESS_TERMCAP_mb = "$(tput bold; tput setaf 2)";
      LESS_TERMCAP_md = "$(tput bold; tput setaf 6)";
      LESS_TERMCAP_me = "$(tput sgr0)";
      LESS_TERMCAP_so = "$(tput bold; tput setaf 3; tput setab 4)";
      LESS_TERMCAP_se = "$(tput rmso; tput sgr0)";
      LESS_TERMCAP_us = "$(tput smul; tput bold; tput setaf 7)";
      LESS_TERMCAP_ue = "$(tput rmul; tput sgr0)";
      LESS_TERMCAP_mr = "$(tput rev)";
      LESS_TERMCAP_mh = "$(tput dim)";
      LESS_TERMCAP_ZN = "$(tput ssubm)";
      LESS_TERMCAP_ZV = "$(tput rsubm)";
      LESS_TERMCAP_ZO = "$(tput ssupm)";
      LESS_TERMCAP_ZW = "$(tput rsupm)";
      LESS = "--quit-if-one-screen";
    };
  };

  programs = {
    exa = {
      enable = true;
      # enableAliases = true; 
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
      '';
      plugins = [{
        name = "fzf.fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }];
      shellInit = ''

        fish_add_path ~/.local/share/bin/
        fzf_configure_bindings --directory=\cf
        fzf_configure_bindings --git_log=\cg
        fzf_configure_bindings --git_status=\cs
        fzf_configure_bindings --history=\cr
        fzf_configure_bindings --variables=\cv
        fzf_configure_bindings --processes=\cp
      '';
      shellAbbrs = {
        hms = "home-manager switch";
        nrs = "sudo nixos-rebuild switch";
        psl = "btm --expanded --default_widget_type=proc";
        pst = "btm --expanded --default_widget_type=proc --tree";
        rm = "trash";
        vic = "vi /etc/nixos/configuration.nix";
        vih = "vi ~/.config/home-manager/home.nix";
        vin = "vi ~/.config/nvim/init.lua";
        sys = "systemctl";
        syu = "systemctl --user";
      };
    };
    fzf.enable = true;
    git = {
      enable = true;
      delta.enable = true;
      signing = {
        signByDefault = true;
        key = null;
      };
    };
    gpg.enable = true;
    home-manager.enable = true;
    ssh = { enable = true; };
    tealdeer = {
      enable = true;
      settings = { auto_update = true; };
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
  };
}
