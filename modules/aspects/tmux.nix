{
  flake.modules.nixos.tmux =
    { inputs, pkgs, ... }:
    {
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.tmux
      ];
    };

  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        tmux
        sesh
        (import ../_scripts/tmux-sessionizer.nix { inherit pkgs; })
      ];

      home.file.".config/tmux/.tmux.conf" = {
        source = ../dotfiles/tmux/.tmux.conf;
      };
    };
}
