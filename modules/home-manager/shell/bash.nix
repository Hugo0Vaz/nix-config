{ ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;

    historyFileSize = -1;
    historySize = -1;
  };
}
