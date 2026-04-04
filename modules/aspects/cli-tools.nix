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
        fido2-manage
        dig
        imagemagick
        btop
        fastfetch
        claude-code
        opencode
        ruby
        udiskie
        direnv
      ];
    };
}
