{ pkgs, self, ... }: {
  imports = [
    ../common/flake-root.nix
    ./waybar
    ./tmux
    ./nvim
    ./ghostty
    ./kitty
    ./starship
    ./hyprland
    ./wofi
    ./monolito

    # ./try.nix
    ./colors.nix
  ];

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
    zoxide
    file
    gh
    pass
    tldr
    fido2-manage
    dig
    imagemagick
    btop
    fastfetch
    claude-code
    opencode
    ruby
  ];

  programs.eza.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "Hugo0Vaz";
      user.email = "hugomartinsvaz@gmail.com";
    };
  };

  programs.fzf.enable = true;
  programs.fzf.enableBashIntegration = true;
  programs.fzf.enableFishIntegration = true;
  programs.fzf.tmux.enableShellIntegration = true;

  programs.fish.enable = true;

  programs.bash = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;
    historyFileSize = -1;
    historySize = -1;
  };

  home.shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";

    "lg" = "lazygit";
    "gs" = "git status";
    "ga" = "git add .";
    "gc" = "git commit -a -m";
    "nd" = "nix develop -c $SHELL";
    "nc" = "nix flake check";
    "nct" = "nix flake check --show-trace";
    "pr" = "OPENAI_API_KEY=$(pass tokens/platform.openai.com/pr-opener) pr-opener";
    "aidme" = "aider --model o3-mini --api-key openai=$(pass tokens/platform.openai.com/aider)";
    "commitme" = "OPENAI_API_KEY=$(pass tokens/platform.openai.com/commiter) commiter";
    "crushme" = "ANTHROPIC_API_KEY=$(pass tokens/console.anthropic.com/crush-ai-nvim) crush";
    "codeme" = "ANTHROPIC_API_KEY='$(pass tokens/console.anthropic.com/nixos-workstation-key)' opencode";
  };

  home.file.".face" = {
    source = "${self}/assets/profile.jpg";
  };

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };

  services.udiskie = {
    enable = true;
    settings = {
        program_options = {
            file_manager = "${pkgs.nautilus}/bin/nautilus";
        };
    };
  };
}
