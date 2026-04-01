{ inputs, pkgs, ... }: {
  imports = [
    inputs.self.modules.homeManager.hugo
    inputs.self.modules.homeManager.cli-tools
    inputs.self.modules.homeManager.shell
    inputs.self.modules.homeManager.tmux
    inputs.self.modules.homeManager.nvim
    inputs.self.modules.homeManager.starship
  ];

  home.username = "hugom";
  home.homeDirectory = "/home/hugom";
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
