{
  flake.modules.nixos.shell =
    { inputs, pkgs, ... }:
    {
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.shell
      ];
    };

  flake.modules.homeManager.shell =
    { pkgs, ... }:
    {
      programs.fzf.enable = true;
      programs.fzf.enableBashIntegration = true;
      programs.fzf.enableFishIntegration = true;
      programs.fzf.tmux.enableShellIntegration = true;

      programs.fish.enable = true;

      programs.bash = {
        enable = true;
        enableCompletion = true;
        enableVteIntegration = true;
        historyFileSize = -1;
        historySize = -1;
      };

      home.shellAliases = {
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";

        "lg" = "lazygit";

        "gs" = "git status";
        "ga" = "git add .";
        "gc" = "git commit -a -m";

        "nd" = "nix develop";
        "nc" = "nix flake check";
        "nct" = "nix flake check --show-trace";

        "pr" = "OPENAI_API_KEY=$(pass tokens/platform.openai.com/pr-opener) pr-opener";
        "aidme" = "aider --model o3-mini --api-key openai=$(pass tokens/platform.openai.com/aider)";
        "commitme" = "OPENAI_API_KEY=$(pass tokens/platform.openai.com/commiter) commiter";
        "crushme" = "ANTHROPIC_API_KEY=$(pass tokens/console.anthropic.com/crush-ai-nvim) crush";
        "codeme" = "ANTHROPIC_API_KEY='$(pass tokens/console.anthropic.com/nixos-workstation-key)' opencode";
      };
    };
}
