{
  flake.modules.nixos.nixosServerConfiguration =
    { inputs, ... }: {
      imports = [
        inputs.self.modules.nixos.nixosServerHardwareConfiguration
        inputs.self.modules.nixos.abnt2
        inputs.self.modules.nixos.cli-tools
        inputs.self.modules.nixos.hugo
        inputs.self.modules.nixos.nvim
        inputs.self.modules.nixos.openssh
        inputs.self.modules.nixos.podman
        inputs.self.modules.nixos.shell
        inputs.self.modules.nixos.sops
        inputs.self.modules.nixos.starship
        inputs.self.modules.nixos.tailscale
        inputs.self.modules.nixos.tmux
        inputs.self.modules.nixos.admin
        inputs.self.modules.nixos.grub
        inputs.self.modules.nixos.linode-networking
      ];

      networking.hostName = "nixos-notebook";
      system.stateVersion = "25.11";
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nixpkgs.config.allowUnfree = true;
    };
}
