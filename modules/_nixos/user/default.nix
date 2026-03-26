{ config, lib, pkgs, ... }:
with lib;
{
  options.monolitoSystem.user = {
    name = mkOption {
      type = types.str;
      default = "monolitoUser";
      description = "Primary user name";
    };

    description = mkOption {
      type = types.str;
      default = "Monolito User";
      description = "User Full Name";
    };

    userShell = mkOption {
      type = types.package;
      default = pkgs.bash;
      description = "The shell package for the Monolito User";

    };

    extraGroups = mkOption {
      type = types.listOf types.str;
      default = ["networkmanager" "wheel"];
      description = "Extra groups for the user";
    };
  };

  config = {
    users.users.${config.monolitoSystem.user.name} = {
      isNormalUser = true;
      description = config.monolitoSystem.user.description;
      extraGroups = config.monolitoSystem.user.extraGroups;
      shell = config.monolitoSystem.user.userShell;
    };

    environment.shells = [ config.monolitoSystem.user.userShell ];
  };
}
