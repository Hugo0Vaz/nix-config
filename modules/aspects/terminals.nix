{
  flake.modules.nixos.terminals =
    { inputs, pkgs, ... }:
    {

      environment.systemPackages =
        with pkgs;
        [
          ghostty
          kitty
        ];

      fonts.packages = with pkgs; [
        iosevka
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
        nerd-fonts.hack
      ];

      fonts.fontconfig.enable = true;

      home-manager.sharedModules = [
        inputs.self.modules.homeManager.terminals
      ];
    };

  flake.modules.homeManager.terminals =
    { config, ... }:
    {
      # Use out-of-store symlinks so that ~/.config/ghostty and ~/.config/kitty
      # remain real writable directories. Tools like matugen/DMS need to write
      # theme files into them (e.g. ~/.config/ghostty/themes/dankcolors).
      home.file.".config/ghostty/config".source =
        config.lib.file.mkOutOfStoreSymlink /home/hugomvs/Projetos/nix-config/modules/dotfiles/ghostty/config;

      home.file.".config/kitty/kitty.conf".source =
        config.lib.file.mkOutOfStoreSymlink /home/hugomvs/Projetos/nix-config/modules/dotfiles/kitty/kitty.conf;
    };
}
