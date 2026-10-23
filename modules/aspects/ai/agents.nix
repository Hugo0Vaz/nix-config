{
  flake.modules.nixos.coding-agents =
    { inputs, pkgs, lib, config, ... }:
    {
      options.services.piAgent.piDotfileRoot = lib.mkOption {
        type = lib.types.str;
        description = "Realpath of the pi agent dotfiles repo";
        example = "/home/hugomvs/Projetos/nix-config/modules/dotfiles/pi/";
      };

      config = {
        home-manager.sharedModules = [
          inputs.self.modules.homeManager.coding-agents
          {
            services.piAgent.piDotfileRoot =
              config.services.piAgent.piDotfileRoot;
          }
        ];
      };
    };

  flake.modules.homeManager.coding-agents =
    { inputs, pkgs, lib, config, ... }:
    let
      llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      options.services.piAgent.piDotfileRoot = lib.mkOption {
        type = lib.types.str;
        description = "Realpath of the pi agent dotfiles repo";
        example = "/home/hugomvs/Projetos/nix-config/modules/dotfiles/pi/";
      };

      config = {
        home.packages = [
          llmAgents.pi
          llmAgents.opencode
          llmAgents.claude-code
          llmAgents.claude-desktop
          llmAgents.orca
          pkgs.libnotify
        ];

        home.file.".pi".source =
          config.lib.file.mkOutOfStoreSymlink config.services.piAgent.piDotfileRoot;
      };
    };
}
