{
  flake.modules.nixos.terminals =
    { inputs, pkgs, ... }:
    {

      environment.systemPackages =
        with pkgs;
        [
          ghostty
          kitty
          alacritty
        ];

      home-manager.sharedModules = [
        inputs.self.modules.homeManager.terminals
      ];
    };

  flake.modules.homeManager.terminals =
    { pkgs, ... }:
    {
      home.file.".config/ghostty" = {
        source = ../dotfiles/ghostty;
      };

      home.file.".config/kitty" = {
        source = ../dotfiles/kitty;
      };
    };
}
