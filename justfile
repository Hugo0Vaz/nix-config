rebuild-switch:
    sudo nixos-rebuild switch --flake .#$(hostname)

rebuild-test:
    sudo nixos-rebuild test --flake .#$(hostname)

check:
    nix flake check
