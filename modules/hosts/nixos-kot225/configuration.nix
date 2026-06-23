{
  flake.modules.nixos.nixosKot225Configuration =
    { inputs, ... }: {
      imports = [
        ./_hardware-configuration.nix
        inputs.self.modules.nixos.nix-settings
        inputs.self.modules.nixos.abnt2
        inputs.self.modules.nixos.audio
        inputs.self.modules.nixos.browsers
        inputs.self.modules.nixos.cli-tools
        inputs.self.modules.nixos.coding-agents
        inputs.self.modules.nixos.desktop
        inputs.self.modules.nixos.hugo
        inputs.self.modules.nixos.kde
        inputs.self.modules.nixos.local-time
        inputs.self.modules.nixos.niri
        inputs.self.modules.nixos.nvidia
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
        # inputs.self.modules.nixos.nix-config-sync-check
      ];

      # my.nixConfigSyncCheck.repoPath = "/home/hugomvs/Projetos/nix-config";
      # my.nixConfigSyncCheck.withNotifications = true;

      services.piAgent.piDotfileRoot = "/home/hugomvs/Projetos/nix-config/modules/dotfiles/pi/";

      # Dual-boot with Windows: keep RTC in local time so both OSes agree.
      time.hardwareClockInLocalTime = true;

      # Kernel NTFS driver for the shared "Vault" HD.
      boot.initrd.supportedFilesystems = [ "ntfs3" ];

      networking.hostName = "nixos-kot225";
      system.stateVersion = "24.05";
    };
}
