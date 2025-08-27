# Agent Guidelines for Nix Configuration Repository

## Build/Test Commands
- **Build NixOS**: `sudo nixos-rebuild switch --flake .#nixos-workstation`
- **Build Home Manager**: `home-manager switch --flake .#hugo-wsl` 
- **Test build without switching**: `nixos-rebuild dry-build --flake .#nixos-workstation`
- **Check flake**: `nix flake check`
- **Update inputs**: `nix flake update`

## Code Style Guidelines
- Use function parameter pattern `{ pkgs, ... }:` for module definitions
- Import statements go at the top: `imports = [ ./module1.nix ./module2.nix ];`
- Use `with pkgs;` for package lists to reduce verbosity
- Follow camelCase for user names and attributes (e.g., `hugomvs`, `homeDirectory`)
- Use kebab-case for package names and module files
- Organize modules by category: `nixos/`, `home-manager/cli/`, `home-manager/gui/`
- Use relative paths for local imports: `./../../modules/nixos/user.nix`
- Always include comments for system state versions and experimental features
- Use `callPackage` for custom packages in `environment.systemPackages`
- Source dotfiles with `home.file` and `source` attributes for configs
- Enable programs with `programs.name.enable = true` pattern
- Use `specialArgs` to pass inputs to modules in flake outputs