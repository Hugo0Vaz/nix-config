{
  flake.modules.nixos.grub-efi =
    { pkgs, ... }:
    {
      boot.loader.grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
        configurationLimit = 5;

        # Install GRUB as the fallback EFI binary (\EFI\BOOT\BOOTX64.EFI).
        # This is required when the firmware boots a disk directly (e.g. a
        # "HDD0" entry in the UEFI boot menu) rather than following the NVRAM
        # BootOrder. In that case the firmware ignores NVRAM entries entirely
        # and looks for the fallback path, so GRUB must live there to be found.
        # Note: efiInstallAsRemovable and canTouchEfiVariables are mutually
        # exclusive — the former is used precisely when EFI variable writes are
        # unreliable or bypassed by the firmware.
        efiInstallAsRemovable = true;
      };

      # Must be false when efiInstallAsRemovable = true (see above).
      boot.loader.efi.canTouchEfiVariables = false;

      boot.plymouth.enable = true;
      boot.initrd.systemd.enable = true;

      boot.kernelParams = [
        "quiet"
        "splash"
      ];

      environment.systemPackages = with pkgs; [
        plymouth
      ];

      # Some firmware implementations (e.g. consumer motherboards with a
      # "HDD0" boot entry) bypass the NVRAM BootOrder and directly execute
      # \EFI\BOOT\BOOTX64.EFI from the ESP. efiInstallAsRemovable = true is
      # supposed to write GRUB there, but in practice it skips the copy when
      # the file already exists (e.g. a leftover systemd-boot binary from a
      # previous install). This activation script enforces the invariant on
      # every rebuild so the fallback path always points to GRUB.
      system.activationScripts.grubFallback = {
        text = ''
          mkdir -p /boot/EFI/BOOT
          cp /boot/EFI/NixOS-boot/grubx64.efi /boot/EFI/BOOT/BOOTX64.EFI
        '';
        deps = [ "specialfs" ];
      };
    };
}
