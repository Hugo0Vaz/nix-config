# Rebuilds the nixos configuration and switches to new generation
rebuild-switch:
    sudo nixos-rebuild switch --flake .#$(hostname)

# Rebuilds the home-manager configuration and switches to new generation
home-switch:
    home-manager switch -b bkp --flake .#"$(whoami)@$(hostname)"

# Checks the flake
check:
    nix flake check

# Checks the flake and rebuild and tests this host configuration without swichting
rebuild-test: check
    nixos-rebuild test --flake .#$(hostname)

# Collects garbage and cleans the repo from temp build files
clean: gc
    rm -rf ./result
    rm -rf ./*.qcow2
    rm -rf ./nixos-switch.log

# Garbage collection
gc days='7d':
    nix-collect-garbage --delete-older-than {{days}}
    sudo nix-collect-garbage --delete-older-than {{days}}
    sudo nix store optimise || sudo nix-store --optimise

# Agressively collect garbage (exclude all without day filter)
agressive-garbage-collection:
    nix-collect-garbage -d
    sudo nix-collect-garbage -d
    sudo nix store optimise || sudo nix-store --optimise

# Deploy local build to remote host (passwordless root SSH)
remote-switch target config='nixos-server':
    case "{{target}}" in root@*) ;; *) echo "target must be root@<ip-or-fqdn> (passwordless ssh)" >&2; exit 1 ;; esac
    NIX_SSHOPTS="-o BatchMode=yes ${NIX_SSHOPTS:-}" nixos-rebuild switch --flake .#{{config}} --target-host "{{target}}"
