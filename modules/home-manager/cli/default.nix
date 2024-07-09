{ pkgs, ... }: {
  home.packages = with pkgs; [ figlet tree zip unzip fzf rclone fd ripgrep ];

  imports = [ ./neovim.nix ];
}
