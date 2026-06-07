{
  flake.modules.nixos.tmux =
    { inputs, pkgs, ... }:
    {
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.tmux
        inputs.self.modules.homeManager.tmux-sessionizer
      ];
    };

  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        tmux
        sesh
        (import ../_scripts/tmux-pane-path.nix { inherit pkgs; })
      ];

      home.file.".tmux.conf" = {
        source = ../dotfiles/tmux/.tmux.conf;
      };
    };
}
