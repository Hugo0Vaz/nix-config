# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Building and Testing
- **NixOS system rebuild**: `sudo nixos-rebuild switch --flake .#nixos-workstation`
- **Home Manager rebuild**: `home-manager switch --flake .#hugo-wsl`
- **Dry run (test without switching)**: `nixos-rebuild dry-build --flake .#nixos-workstation`
- **Check flake validity**: `nix flake check`
- **Update flake inputs**: `nix flake update`

### Custom Scripts
The repository includes custom rebuild scripts available as packages:
- `rebuildSystem` - Interactive NixOS rebuild with git integration
- `rebuildHome` - Interactive Home Manager rebuild with configuration detection

## Architecture

### Flake Structure
This is a Nix flakes-based configuration supporting multiple host types:
- **NixOS systems**: Full system configurations (nixos-workstation)
- **Home Manager only**: User environment on non-NixOS systems (hugo-wsl)

### Module Organization
```
modules/
├── nixos/          # System-level NixOS modules
├── home-manager/   # User environment modules
│   ├── cli/        # Command-line tools and configurations
│   ├── gui/        # GUI applications and window managers
│   ├── shell/      # Shell configurations (fish, bash, aliases)
│   ├── lang/       # Programming language environments
│   └── scripts/    # Custom utility scripts
└── custom/         # Custom package definitions
```

### Configuration Pattern
- Host configurations in `hosts/*/configuration.nix` and `hosts/*/home.nix`
- Modular imports with `default.nix` files for each category
- Custom packages defined using `callPackage` pattern
- Git integration in rebuild scripts for automatic commits

### Key Conventions
- Use `{ pkgs, ... }:` parameter pattern for modules
- Import local modules with relative paths: `./../../modules/nixos/`
- Package lists use `with pkgs;` for brevity
- Enable programs with `programs.name.enable = true`
- Custom packages built using `buildGoModule` and `fetchFromGitHub`
- State versions set to "24.05" across configurations

## Custom Packages
- **commiter**: Go-based commit tool (v0.1.0)
- **propener**: Custom utility package