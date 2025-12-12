{ lib, config, ... }:
{
  options.monolitoSystem.boot = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enables boot options";
    };
    
    type = lib.mkOption {
      type = lib.types.enum [ "none" "systemd-boot" "grub" ];
      default = "systemd-boot";
      description = ''
        Bootloader type:
        - none: No bootloader configuration
        - systemd-boot: Simple UEFI bootloader (default)
        - grub: GRUB 2 bootloader for BIOS/UEFI
      '';
    };
    
    efiSupport = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable EFI support (required for systemd-boot)";
    };
    
    consoleMode = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "0" "1" "2" "max" "auto" ]);
      default = "max";
      description = "systemd-boot console mode (null to disable)";
    };
    
    plymouth.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Plymouth boot splash";
    };
    
    # GRUB-specific options
    grubDevice = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "GRUB device (e.g., /dev/sda). Required for BIOS systems.";
    };
  };

  config = lib.mkIf config.monolitoSystem.boot.enable {
    boot.loader.efi.canTouchEfiVariables = lib.mkIf (config.monolitoSystem.boot.efiSupport && config.monolitoSystem.boot.type != "none") 
      config.monolitoSystem.boot.efiSupport;
    
    boot.loader.systemd-boot = {
      enable = config.monolitoSystem.boot.type == "systemd-boot";
      consoleMode = lib.mkIf (config.monolitoSystem.boot.type == "systemd-boot" && config.monolitoSystem.boot.consoleMode != null) 
        config.monolitoSystem.boot.consoleMode;
    };
    
    boot.loader.grub = lib.mkIf (config.monolitoSystem.boot.type == "grub") {
      enable = true;
      efiSupport = config.monolitoSystem.boot.efiSupport;
      device = lib.mkIf (config.monolitoSystem.boot.grubDevice != null) config.monolitoSystem.boot.grubDevice;
    };
    
    boot.plymouth.enable = config.monolitoSystem.boot.plymouth.enable;
    
    # Validation to prevent misconfiguration
    assertions = [
      {
        assertion = !(config.monolitoSystem.boot.type == "systemd-boot" && !config.monolitoSystem.boot.efiSupport);
        message = "systemd-boot requires EFI support to be enabled";
      }
      {
        assertion = !(config.monolitoSystem.boot.type == "grub" && !config.monolitoSystem.boot.efiSupport && config.monolitoSystem.boot.grubDevice == null);
        message = "GRUB for BIOS systems requires grubDevice to be specified";
      }
    ];
  };
}
