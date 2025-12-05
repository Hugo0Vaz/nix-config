{ lib, config, ... }:
{
  options.monolitoSystem.boot = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enables boot options";
    };
  };

  config = lib.mkIf config.monolitoSystem.boot.enable {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.consoleMode = "max";
    boot.plymouth.enable = true;
  };
}
