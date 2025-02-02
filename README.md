# nix-config
My Nix, NixOS and Home-Manager config based on flakes.

# nix-config v2

- Better module separation.
- Configurable capabilities that can be set in flake.nix per host configuration.
- Support several types of hosts:
    - Server (NixOS and non-NixOS).
    - NixOS based desktop system.
    - Non-NixOS based desktop systems.
    - WSL (Ubuntu) based systems.
    - Darwin systems.
