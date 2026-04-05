{
  flake.modules.nixos.nixosNotebookConfiguration =
  { inputs, self, ... }: {
    imports = [
      self.modules.nixos.nixosNotebookHardwareConfiguration
      self.modules.nixos.hugo
      self.modules.nixos.systemd-boot
      self.modules.nixos.abnt2
      self.modules.nixos.local-time
      self.modules.nixos.audio
      self.modules.nixos.cli-tools
      self.modules.nixos.shell
      self.modules.nixos.tmux
      self.modules.nixos.nvim
      self.modules.nixos.starship
      self.modules.nixos.terminals
      self.modules.nixos.browsers
      self.modules.nixos.podman
      self.modules.nixos.tailscale
      self.modules.nixos.openssh
      self.modules.nixos.niri
      inputs.home-manager.nixosModules.home-manager
    ];

    networking.hostName = "nixos-notebook2";
    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = "24.05";
  };
}
