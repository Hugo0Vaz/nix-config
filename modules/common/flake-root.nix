{ config, lib, ... }:
with lib;
{
  options.monolitoSystem.flakeRoot = mkOption {
    type = types.str;
    description = ''
      Absolute path to the flake repository root directory.
      
      This path is used by mkOutOfStoreSymlink to create symlinks to configuration
      files in your dotfiles repository, allowing you to edit them directly without
      rebuilding.
      
      Must be set explicitly for each host based on where the nix-config repository
      is located on that system.
    '';
    example = "/home/username/Projetos/nix-config";
  };

  config = {
    # Assertion to ensure flakeRoot is set
    assertions = [
      {
        assertion = config.monolitoSystem.flakeRoot != "";
        message = ''
          You must set 'monolitoSystem.flakeRoot' to the absolute path of your nix-config repository.
          
          Add this to your configuration.nix or home.nix:
            monolitoSystem.flakeRoot = "/path/to/your/nix-config";
          
          Example:
            monolitoSystem.flakeRoot = "/home/username/Projetos/nix-config";
        '';
      }
    ];

    # Export to _module.args for backward compatibility with existing modules
    _module.args.flakeRoot = config.monolitoSystem.flakeRoot;
  };
}
