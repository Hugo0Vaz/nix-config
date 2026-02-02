{ pkgs }:

pkgs.writeShellScriptBin "tmux-worktree-sessionizer" ''
  repo_root="$1"
  if [[ -z $repo_root ]]; then
      echo "Usage: tmux-worktree-sessionizer <repo_root>"
      exit 1
  fi

  echo "$repo_root"

  sleep 5

  selected=$(git -C "$repo_root" worktree list | awk '{ print $1 }' | fzf)

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
