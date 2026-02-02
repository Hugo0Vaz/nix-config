{ pkgs }:

pkgs.writeShellScriptBin "tmux-worktree-sessionizer" ''
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      exit 0
      echo "Not inside git repo!"
  fi

  selected=$(git worktree list | awk '{ print $1 }' | fzf)

  if [[ -z $selected ]]; then
      exit 0
  fi

  selected_name=$(basename "$selected" | tr . _)
  tmux_running=$(pgrep tmux)

  echo $selected

  if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
      tmux new-session -s $selected_name -c $selected
      exit 0
  fi

  if ! tmux has-session -t=$selected_name 2> /dev/null; then
      tmux new-session -ds $selected_name -c $selected
  fi

  tmux switch-client -t $selected_name
''
