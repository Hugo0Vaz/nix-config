{
  flake.modules.nixos.nixosKot225Configuration =
    { inputs, ... }: {
      imports = [
        inputs.self.modules.nixos.nixosKot225HardwareConfiguration
        inputs.self.modules.nixos.abnt2
        inputs.self.modules.nixos.admin
        inputs.self.modules.nixos.audio
        inputs.self.modules.nixos.browsers
        inputs.self.modules.nixos.cli-tools
        inputs.self.modules.nixos.desktop
        inputs.self.modules.nixos.hugo
        inputs.self.modules.nixos.local-time
        inputs.self.modules.nixos.niri-kot225
        inputs.self.modules.nixos.nvim
        inputs.self.modules.nixos.office
        inputs.self.modules.nixos.openssh
        inputs.self.modules.nixos.ssh-authorized-keys
        inputs.self.modules.nixos.podman
        inputs.self.modules.nixos.shell
        inputs.self.modules.nixos.sops
        inputs.self.modules.nixos.starship
        inputs.self.modules.nixos.grub-efi
        inputs.self.modules.nixos.tailscale
        inputs.self.modules.nixos.terminals
        inputs.self.modules.nixos.tmux
      ];

      networking.hostName = "nixos-kot225";
      nixpkgs.config.allowUnfree = true;
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      system.stateVersion = "24.05";
    };
}
