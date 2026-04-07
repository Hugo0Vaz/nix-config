rebuild-switch:
    sudo nixos-rebuild switch --flake .#$(hostname)

rebuild-test:
    nixos-rebuild test --flake .#$(hostname)

rebuild-vm hostname:
    nixos-rebuild build-vm --flake .#{{hostname}}

run-vm hostname:
    nixos-rebuild build-vm --flake .#{{hostname}}

home-switch:
    home-manager switch -b bkp --flake .#$(whoami)

check:
    nix flake check

clean:
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
