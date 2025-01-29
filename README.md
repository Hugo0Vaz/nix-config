# nix-config
My Nix, NixOS and Home-Manager config based on flakes.

# nix-config v2

- separar os módulos de forma mais clara.
- preparar algumas configurações diferentes de home-manager dependentes de host.
- hosts que serão configurados:
    - nixos-workstation
    - nixos-notebook
    - nixos-server
    - ubuntu (WSL que uso no trabalho)
- concentrar as instalações de desktop nas configurações de NixOS, mas as ferramentas de CLI no Home-Manager
