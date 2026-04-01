{ inputs, pkgs, ... }: {
  imports = [
    inputs.self.modules.homeManager.hugo
    inputs.self.modules.homeManager.cli-tools
    inputs.self.modules.homeManager.shell
    inputs.self.modules.homeManager.tmux
    inputs.self.modules.homeManager.nvim
    inputs.self.modules.homeManager.starship
    inputs.self.modules.homeManager.terminals
    # inputs.self.modules.homeManager.niri  # TODO: add noctalia input to flake.nix
  ];

  home.username = "hugomvs";
  home.homeDirectory = "/home/hugomvs";
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
