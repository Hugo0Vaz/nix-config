rebuild-switch:
    sudo nixos-rebuild switch --flake .#$(hostname)

home-switch:
    home-manager switch -b bkp --flake .#$(whoami)

check:
    nix flake check

rebuild-test: check
    nixos-rebuild test --flake .#$(hostname)

clean: gc
    rm -rf ./result
    rm -rf ./*.qcow2
    rm -rf ./nixos-switch.log

gc days='7d':
    nix-collect-garbage --delete-older-than {{days}}
    sudo nix-collect-garbage --delete-older-than {{days}}
    sudo nix store optimise || sudo nix-store --optimise

agressive-garbage-collection:
    nix-collect-garbage -d
    sudo nix-collect-garbage -d
    sudo nix store optimise || sudo nix-store --optimise
