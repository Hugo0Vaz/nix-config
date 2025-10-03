{ pkgs, ... }: {
  home.packages = with pkgs; [
    figlet
    tree
    zip
    unzip
    fzf
    rclone
    fd
    ripgrep
    lazygit
    nix-direnv
    zoxide
    file
    aider-chat
    gh
    pass
    go-blueprint
    uv
    tldr
    fido2-manage
    dig
    imagemagick
    btop
  ];

  programs.eza.enable = true;

  services.openssh = {
  enable = true;            # Enable the SSH server
  openFirewall = true;      # Open port 22 in the firewall (if using NixOS firewall)
  settings = {
    PermitRootLogin = "no"; # Disable root login (recommended)
    PasswordAuthentication = true; # Allow password login (set false if you want only keys)
  };
};

  imports = [ ./neovim.nix ./tmux.nix ./git.nix ./ai.nix];
}
