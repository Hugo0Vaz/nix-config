{
  flake.modules.nixos.noctalia =
    { inputs, pkgs, lib, config, ... }:
    {
      options.my.noctalia = {
        enable = lib.mkEnableOption "Noctalia desktop shell";

        config = lib.mkOption {
          type = lib.types.path;
          default = ../dotfiles/noctalia/noctalia.json;
          description = "Path to the noctalia settings JSON file.";
        };
      };

      config = lib.mkIf config.my.noctalia.enable {
        environment.systemPackages = with pkgs; [
          noctalia-shell
        ];

        home-manager.sharedModules = [
          inputs.self.modules.homeManager.noctalia
          {
            my.noctalia.config = config.my.noctalia.config;
          }
        ];
      };
    };

  flake.modules.homeManager.noctalia =
    { lib, config, ... }:
    {
      options.my.noctalia = {
        enable = lib.mkEnableOption "Noctalia desktop shell";

        config = lib.mkOption {
          type = lib.types.path;
          default = ../dotfiles/noctalia/noctalia.json;
          description = "Path to the noctalia settings JSON file.";
        };
      };

      config = lib.mkIf config.my.noctalia.enable {
        home.file.".config/noctalia/settings.json".source =
          config.my.noctalia.config;
      };
    };
}
