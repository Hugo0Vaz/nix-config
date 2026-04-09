rebuild-switch:
    sudo nixos-rebuild switch --flake .#$(hostname)

home-switch:
    home-manager switch -b bkp --flake .#"$(whoami)@$(hostname)"

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

# Deploy local build to remote host (passwordless root SSH)
remote-switch target config='nixos-server':
    case "{{target}}" in root@*) ;; *) echo "target must be root@<ip-or-fqdn> (passwordless ssh)" >&2; exit 1 ;; esac
    NIX_SSHOPTS="-o BatchMode=yes ${NIX_SSHOPTS:-}" nixos-rebuild switch --flake .#{{config}} --target-host "{{target}}"
