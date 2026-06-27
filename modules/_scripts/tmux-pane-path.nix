{ pkgs }:
pkgs.writeShellScriptBin "tmux-pane-path" ''
  # Print pane_current_path with intermediate dirs shortened to first letter.
  # e.g. ~/Projetos/nix-config → ~/P/nix-config
  #      /home/user/dev/project → /h/u/d/project

  p="''${TMUX_PANE_CURRENT_PATH:-$(tmux display -p '#{pane_current_path}')}"
  case "$p" in
    "$HOME"*) p="~''${p#"$HOME"}" ;;
  esac

  echo "$p" | awk -F/ '{
    last=$NF
    for(i=1;i<NF;i++) printf "%s/",($i==""?"":substr($i,1,1))
    print last
  }'
''
