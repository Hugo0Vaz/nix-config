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
      shell = pkgs.fish;
    };
  };
}
