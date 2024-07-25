{ pkgs }:

pkgs.writeShellScriptBin "rebuildSystem" ''
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
    fi

    git add $PWD

    sudo nixos-rebuild switch --flake $PWD &>nixos-switch.log || (cat nixos-switch.log | grep --color error && false)

    gen=$(nixos-rebuild list-generations | grep current)
    git commit -am "$gen"
''
