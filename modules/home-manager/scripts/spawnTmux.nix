{ pkgs }:

pkgs.writeShellScriptBin "spawnTmux" ''
    tmux attach-session -t start || tmux new-session -s start
''
