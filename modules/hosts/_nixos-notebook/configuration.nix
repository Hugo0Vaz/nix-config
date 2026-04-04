{ inputs, ... }: {
  imports = [
    inputs.self.modules.nixos.hugo
    inputs.self.modules.nixos.systemd-boot
    inputs.self.modules.nixos.abnt2
    inputs.self.modules.nixos.local-time
    inputs.self.modules.nixos.audio
    inputs.self.modules.nixos.cli-tools
    inputs.self.modules.nixos.shell
    inputs.self.modules.nixos.tmux
    inputs.self.modules.nixos.nvim
    inputs.self.modules.nixos.starship
    inputs.self.modules.nixos.terminals
    inputs.self.modules.nixos.browsers
    inputs.self.modules.nixos.podman
    inputs.self.modules.nixos.tailscale
    inputs.self.modules.nixos.openssh
    inputs.self.modules.nixos.niri  # TODO: add noctalia input to flake.nix
    # inputs.self.modules.nixos.nvidia  # notebook uses Intel integrated graphics
  ];

  networking.hostName = "nixos-notebook";
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.05";
}
