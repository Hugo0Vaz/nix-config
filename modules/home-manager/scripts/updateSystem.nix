{ pkgs }:

pkgs.writeShellScriptBin "updateSystem" ''
  set -e
  if [[ ! -e "$PWD/flake.nix" ]]; then
      echo "There is no file flake.nix in $PWD"
      exit 1
  fi

  echo "Updating flakes..." | ${pkgs.cowsay}/bin/cowsay
  echo "Will be updating the flake.lock from $PWD"
  read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

  nix flake update
''
