rebuild-switch:
    sudo nixos-rebuild switch --flake .#$(hostname)

rebuild-test:
    sudo nixos-rebuild test --flake .#$(hostname)

home-switch:
    home-manager switch -b bkp --flake .#$(whoami)

check:
    nix flake check
