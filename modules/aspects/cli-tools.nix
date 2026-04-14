{
  flake.modules.nixos.cli-tools =
    { inputs, pkgs, ... }:
    {
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.cli-tools
      ];
    };

  flake.modules.homeManager.cli-tools =
    { pkgs, ... }:
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
        zoxide
        file
        gh
        pass
        tldr
        vim
        wget
        inetutils
        mtr
        sysstat
        dig
        imagemagick
        btop
        fastfetch
        opencode
        direnv
        bitwarden-cli
        wl-clipboard
        xclip
        (import ../_scripts/spawn-tmux.nix { inherit pkgs; })
        (import ../_scripts/secret-manager.nix { inherit pkgs; })
      ];

      programs.eza = {
        enable = true;
        enableFishIntegration = true;
        enableBashIntegration = true;
      };
    };
}
