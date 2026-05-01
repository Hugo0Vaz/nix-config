{ pkgs }:

pkgs.writeShellScriptBin "clonetree" ''
  if [[ "$#" -eq 0 || "$#" -eq 1 ]]; then
    echo "No arguments provided."
    echo "Usage:"
    echo "  clonetree <GIT_REPO> <REPO_DIR>"
  fi

  GIT_REMOTE=$1
  REPO_DIR=$2

  if [[ ! -d $REPO_DIR ]]; then
    echo "Creating the directory: $REPO_DIR"
    mkdir -p $REPO_DIR
  fi

  cd $REPO_DIR

  git clone --bare $GIT_REMOTE .bare

  echo "gitdir: ./.bare" > .git
  
  git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

  echo "Worktree setup finished in $REPO_DIR"
  echo "Run `git worktree add main` to add your first worktree"
''
