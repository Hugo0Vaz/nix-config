{...}:
let
    home = home.homeDirectory;
in {
programs.bash = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;

    historyFile = "${home}" + "bash_history";
    historyFileSize = -1;
    historySize = -1;
};
}
