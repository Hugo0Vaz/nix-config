{...}:

{
  home.shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";

    "lg" = "lazygit";
    "gs" = "git status";
    "ga" = "git add .";
    "gc" = "git commit -a -m";
    "pr" = "OPENAI_API_KEY=$(pass tokens/platform.openai.com/pr-opener) pr-opener";
    "aidme" = "aider --model o3-mini --api-key openai=$(pass tokens/platform.openai.com/aider)";
    "commitme" = "OPENAI_API_KEY=$(pass tokens/platform.openai.com/commiter) commiter";
    "crushme" = "ANTHROPIC_API_KEY=$(pass tokens/console.anthropic.com/crush-ai-nvim) crush";
    "opencode" = "crush";
  };
}
