{
  flake.modules.homeManager.kot225wslHomeConfiguration =
    { inputs, lib, ... }:
    {
      imports = [
        inputs.self.modules.homeManager.hugo
        inputs.self.modules.homeManager.cli-tools
        inputs.self.modules.homeManager.shell
        inputs.self.modules.homeManager.tmux
        inputs.self.modules.homeManager.starship
        inputs.self.modules.homeManager.nvim
        inputs.self.modules.homeManager.sops
      ];

      targets.genericLinux.enable = true;

      home.username = "hugom";
      home.homeDirectory = "/home/hugom";
      home.stateVersion = "24.05";
      programs.home-manager.enable = true;
    };
}
