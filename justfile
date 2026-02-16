rebuild-switch:
    sudo nixos-rebuild switch --flake .#$(hostname)

rebuild-test:
    nixos-rebuild test --flake .#$(hostname)

rebuild-vm hostname:
    nixos-rebuild build-vm --flake .#{{hostname}}

home-switch:
    home-manager switch -b bkp --flake .#$(whoami)

check:
    nix flake check

clean:
    rm -rf ./result
    rm -rf ./*.qcow2
