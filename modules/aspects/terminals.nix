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
      home.file.".config/ghostty" = {
        source = ../dotfiles/ghostty;
      };

      home.file.".config/kitty" = {
        source = ../dotfiles/kitty;
      };
    };
}
