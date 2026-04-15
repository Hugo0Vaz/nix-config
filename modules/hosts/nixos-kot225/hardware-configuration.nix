{
  flake.modules.nixos.nixosKot225HardwareConfiguration =
  { config, lib, pkgs, modulesPath, ... }:
  {
    imports =
      [ (modulesPath + "/installer/scan/not-detected.nix")
      ];
  
    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];
  
    fileSystems."/" =
      { device = "/dev/disk/by-uuid/ff70d570-b3f0-426b-be3f-7f496d13ac75";
        fsType = "ext4";
      };
  
    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/C093-DFFB";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };
  
    swapDevices =
      [ { device = "/dev/disk/by-uuid/3eb65f01-9486-4b20-b1a4-fea404f0bdb9"; }
      ];
  
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
