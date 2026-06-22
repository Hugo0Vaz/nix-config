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
    { ... }:
    {
      # Use individual file entries instead of whole-directory symlinks so that
      # tools like matugen/DMS can write theme files into ~/.config/ghostty/ and
      # ~/.config/kitty/ (otherwise the directories are read-only Nix store symlinks).
      home.file.".config/ghostty/config".source = ../dotfiles/ghostty/config;

      home.file.".config/kitty/kitty.conf".source = ../dotfiles/kitty/kitty.conf;
    };
}
