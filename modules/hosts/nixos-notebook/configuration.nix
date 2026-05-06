{
  flake.modules.nixos.nixosNotebookConfiguration =
    { inputs, ... }: {
      imports = [
        inputs.self.modules.nixos.nixosNotebookHardwareConfiguration
        inputs.self.modules.nixos.nix-settings
        inputs.self.modules.nixos.abnt2
        inputs.self.modules.nixos.admin
        inputs.self.modules.nixos.audio
        inputs.self.modules.nixos.browsers
        inputs.self.modules.nixos.cli-tools
        inputs.self.modules.nixos.desktop
        inputs.self.modules.nixos.hugo
        inputs.self.modules.nixos.local-time
        inputs.self.modules.nixos.niri
        inputs.self.modules.nixos.nvim
        inputs.self.modules.nixos.office
        inputs.self.modules.nixos.openssh
        inputs.self.modules.nixos.ssh-authorized-keys
        inputs.self.modules.nixos.podman
        inputs.self.modules.nixos.shell
        inputs.self.modules.nixos.sops
        inputs.self.modules.nixos.starship
        inputs.self.modules.nixos.systemd-boot
        inputs.self.modules.nixos.tailscale
        inputs.self.modules.nixos.terminals
        inputs.self.modules.nixos.tmux
        inputs.self.modules.nixos.nix-config-sync-check
      ];

      my.nixConfigSyncCheck.withNotifications = true;

      networking.hostName = "nixos-notebook";
      system.stateVersion = "24.05";
    };
}
