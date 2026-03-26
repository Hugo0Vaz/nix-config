{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
  };

  home.packages = with pkgs; [
    sesh
  ];

  home.file.".tmux.conf" = {
    source = ./.tmux.conf;
  };
}
