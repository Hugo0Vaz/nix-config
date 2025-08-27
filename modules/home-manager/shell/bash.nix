{ pkgs, ... }:
{

  home.sessionVariables = {
    SHELL = "${pkgs.fish}/bin/fish";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;

    initExtra = ''
      export PATH="$HOME/.npm-global/bin:$PATH"
    '';

    bashrcExtra = ''
      # If SHELL is set to fish and we're interactive, start fish
      if [[ $- == *i* ]] && [[ "$SHELL" == *"fish"* ]] && command -v fish >/dev/null 2>&1; then
        if [[ -z "$BASH_EXECUTION_STRING" && -z "$FISH_VERSION" ]]; then
          exec fish
        fi
      fi
    '';

    historyFileSize = -1;
    historySize = -1;
  };
}
