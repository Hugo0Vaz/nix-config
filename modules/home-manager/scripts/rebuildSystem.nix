{ pkgs }:

pkgs.writeShellScriptBin "rebuildSystem" ''
    set -e
    if [[ ! -e "$PWD/flake.nix" ]]; then
        echo "There is no file flake.nix in $PWD"
        exit 1
    fi

    echo "Rebuilding the NixOS config..." | ${pkgs.cowsay}/bin/cowsay
    echo "Will be rebuilding the flake.nix from $PWD"
    read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

    if [[ $(git diff --stat) != "" ]]; then
        echo "The current git tree is dirty..."
        read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
        ${pkgs.git}/bin/git add $PWD
    fi

    sudo -v

    sudo nixos-rebuild switch --flake $PWD |& ${pkgs.nix-output-monitor}/bin/nom

    if [[ -n "$(git status --porcelain)" ]]; then
        echo "Fazendo o commit `$gen`"
        gen=$(nixos-rebuild list-generations | grep current)
        ${pkgs.git}/bin/git commit -am "$gen"
    else
        echo "Built... No commits to make..."
    fi
''
