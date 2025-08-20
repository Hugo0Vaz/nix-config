# Nix Configuration Repository

## Build & System Commands
```bash
# Rebuild NixOS configuration (from repo root with flake.nix)
sudo nixos-rebuild switch --flake .
# Rebuild with specific host
sudo nixos-rebuild switch --flake .#nixos-workstation
# Build without switching
nixos-rebuild build --flake .
# Update flake inputs
nix flake update
# Check flake
nix flake check
# Format Nix files
nixpkgs-fmt .
```

## Code Style Guidelines
- **File Structure**: Nix modules use attribute sets with inputs as function parameters
- **Function Parameters**: Use `{ pkgs, ... }:` or `{ config, pkgs, lib, ... }:` pattern
- **Formatting**: 2-space indentation, opening brace on same line as function
- **Attribute Sets**: Multi-line with semicolons, align equals signs when sensible
- **Lists**: Use `with pkgs;` for package lists, one item per line for readability
- **Imports**: Place at module level, use relative paths from repo root
- **Module Pattern**: `{ enable = true; }` for enabling programs/services
- **Shell Scripts**: Use `pkgs.writeShellScriptBin` for custom scripts
- **Comments**: Minimal, only when necessary for complex logic

## Repository Structure
- `flake.nix`: Main entry point, defines nixosConfigurations and homeConfigurations
- `hosts/`: Machine-specific configurations (configuration.nix, home.nix)
- `modules/nixos/`: System-level NixOS modules
- `modules/home-manager/`: User-level Home Manager modules
- `modules/custom/`: Custom packages and overlays
- `dotfiles/`: Configuration files for various programs