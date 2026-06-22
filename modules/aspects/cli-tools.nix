{
  flake.modules.nixos.cli-tools =
    { inputs, pkgs, ... }:
    {
      imports = [
        inputs.self.modules.nixos.cli-base
      ];
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.cli-tools
      ];
    };

  flake.modules.homeManager.cli-tools =
    { inputs, pkgs, ... }:
    {
      imports = [
        inputs.self.modules.homeManager.cli-base
      ];
      home.packages = with pkgs; [
        figlet
        rclone
        lazygit
        gh
        pass
        tldr
        imagemagick
        btop
        fastfetch
        direnv
        bitwarden-cli
        podman-compose
        rbw
        wl-clipboard
        zoxide
        xclip
        devenv
        (import ../_scripts/spawn-tmux.nix { inherit pkgs; })
        (import ../_scripts/secret-manager.nix { inherit pkgs; })
        (import ../_scripts/clone-tree.nix { inherit pkgs; })
      ];

      programs.fish.interactiveShellInit = ''
        zoxide init fish | source
      '';

      programs.eza = {
        enable = true;
        enableFishIntegration = true;
        enableBashIntegration = true;
      };
    };
}
