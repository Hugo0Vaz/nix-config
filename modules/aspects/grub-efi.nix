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
      };

      # Create a NVRAM boot entry so the firmware shows "NixOS" in the
      # boot menu. Most UEFI firmwares require this — they won't autodetect
      # a disk purely from the fallback EFI path.
      boot.loader.efi.canTouchEfiVariables = true;

      boot.plymouth.enable = true;
      boot.initrd.systemd.enable = true;

      boot.kernelParams = [
        "quiet"
        "splash"
      ];

      environment.systemPackages = with pkgs; [
        plymouth
      ];

      # Also install GRUB to the removable/fallback path (\EFI\BOOT\BOOTX64.EFI)
      # as a safety net: if the NVRAM entries ever get cleared (BIOS reset,
      # CMOS battery replacement, etc.), the firmware can still find and boot
      # GRUB via the fallback path.
      boot.loader.grub.extraGrubInstallArgs = [
        "--removable"
      ];
    };
}
