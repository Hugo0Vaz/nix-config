{
  flake.modules.nixos.coding-agents =
    { inputs, pkgs, lib, ... }:
    {
      options.services.myLaravelApp = {
        piRoot = lib.mkOption {
          type = lib.types.str;
          description = "Realpath of the pi agent user global root";
          example = "/home/hugomvs/.pi/";
        };

        piDotfileRoot = lib.mkOption {
          type = lib.types.str;
          description = "Realpath of the pi agent dotfiles repo";
          example = "/home/hugomvs/Projetos/nix-config/modules/dotfiles/pi/";
        };
      };

      home-manager.sharedModules = [
        inputs.self.modules.homeManager.coding-agents
      ];
    };

  flake.modules.homeManager.coding-agents =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        opencode
        pi-coding-agent
      ];
    };
}
