{ config, self, ... }: {
  programs.tmux = {
    enable = true;
  };

  home.packages = with pkgs; [
    sesh
  ];

  home.file.".tmux.conf" = {
    source = config.lib.file.mkOutOfStoreSymlink "${self}/modules/home-manager/tmux/.tmux.conf";
  };
}
