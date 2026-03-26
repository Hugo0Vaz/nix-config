{ pkgs }:

pkgs.writeShellScriptBin "tmux-bare-worktree-sessionizer" ''
  git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null)

  if [[ $? -ne 0 ]]; then
      echo "Error: not inside a git repository"
      exit 1
  fi

  is_bare=$(git -C "$git_common_dir" rev-parse --is-bare-repository 2>/dev/null)

  if [[ "$is_bare" != "true" ]]; then
      echo "Error: not inside a bare git repository"
      exit 1
  fi

  selected=$(git -C "$git_common_dir" worktree list | awk '{ print $1 }' | fzf)

  if [[ -z $selected ]]; then
      exit 0
  fi

  repo_name=$(basename "$git_common_dir" | sed 's/\.git$//' | tr . _)
  worktree_name=$(basename "$selected" | tr . _)
  selected_name="$repo_name/$worktree_name"
  tmux_running=$(pgrep tmux)

  if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
      tmux new-session -s $selected_name -c $selected
      exit 0
  fi

  if ! tmux has-session -t=$selected_name 2> /dev/null; then
      tmux new-session -ds $selected_name -c $selected
  fi

  tmux switch-client -t $selected_name
''
