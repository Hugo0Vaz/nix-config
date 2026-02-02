{ config, flakeRoot, pkgs, ... }: {
  programs.tmux = {
    enable = true;
  };

  home.packages = with pkgs; [
    sesh
  ];

  home.file.".tmux.conf" = {
    source = config.lib.file.mkOutOfStoreSymlink "${flakeRoot}/modules/home-manager/tmux/.tmux.conf";
  };
}
