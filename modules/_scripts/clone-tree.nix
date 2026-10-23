{ pkgs }:

pkgs.writeShellScriptBin "clonetree" ''
  set -euo pipefail

  if [[ "$#" -lt 1 || "$#" -gt 2 ]]; then
    echo "Usage:"
    echo "  clonetree <GIT_REPO> [REPO_DIR]"
    exit 2
  fi

  GIT_REMOTE=$1
  REPO_DIR=''${2:-$(basename "$GIT_REMOTE" .git)}

  if [[ -d "$REPO_DIR" && -n "$(ls -A "$REPO_DIR")" ]]; then
    echo "Error: $REPO_DIR already exists and is not empty." >&2
    exit 1
  fi

  mkdir -p "$REPO_DIR"

  # Bare clone straight into .git: the project root is the repository.
  ${pkgs.git}/bin/git clone --bare --single-branch "$GIT_REMOTE" "$REPO_DIR/.git"

  # Bare clones have no remote tracking refs; configure them and fetch all branches.
  ${pkgs.git}/bin/git -C "$REPO_DIR" config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
  ${pkgs.git}/bin/git -C "$REPO_DIR" fetch origin

  DEFAULT_BRANCH=$(${pkgs.git}/bin/git -C "$REPO_DIR" symbolic-ref --short HEAD)
  ${pkgs.git}/bin/git -C "$REPO_DIR" worktree add "$DEFAULT_BRANCH" "$DEFAULT_BRANCH"

  echo
  ${pkgs.git}/bin/git -C "$REPO_DIR" worktree list
  echo
  echo "Worktree setup finished in $REPO_DIR"
  echo "Daily workflow (run inside $REPO_DIR):"
  echo "  git worktree add <name> origin/<branch>        # existing remote branch"
  echo "  git worktree add -b <new> <name> $DEFAULT_BRANCH   # new branch"
  echo "  git worktree remove <name>                     # when done"
''
