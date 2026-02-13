{ pkgs }:

pkgs.writeShellScriptBin "githubClone" ''
  set -euo pipefail

  org="$1"
  if [ -z "$org" ]; then
    org=$(${pkgs.gh}/bin/gh org list | ${pkgs.fzf}/bin/fzf)
  fi

  repo=$(${pkgs.gh}/bin/gh repo list "$org" --limit 500 --json nameWithOwner --jq '.[].nameWithOwner' | ${pkgs.fzf}/bin/fzf)

  printf "Clone to (path, blank for current dir): "
  read -r target

  if [ -z "$target" ]; then
    ${pkgs.gh}/bin/gh repo clone "$repo"
  else
    ${pkgs.gh}/bin/gh repo clone "$repo" "$target"
  fi
''
