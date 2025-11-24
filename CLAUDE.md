# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix flake-based configuration repository managing NixOS system configurations and Home Manager profiles. The repository supports multiple host types:
- NixOS workstation with integrated Home Manager
- WSL (Ubuntu) systems with standalone Home Manager
- Non-NixOS Ubuntu systems with standalone Home Manager

## Repository Structure

### Flake Architecture
- `flake.nix`: Main flake file defining all system and home configurations
- `flake.lock`: Locked dependency versions
- Primary inputs: nixpkgs (nixos-unstable), home-manager, nix-ai-tools

### Host Configurations
Each host has its own directory under `hosts/`:
- `hosts/nixos-workstation/`: NixOS workstation configuration
  - `configuration.nix`: System-level NixOS configuration
  - `home.nix`: Home Manager configuration for user `hugomvs`
  - `hardware-configuration.nix`: Hardware-specific settings (generated)
- `hosts/wsl/`: WSL-specific Home Manager configuration
- `hosts/ubuntu/`: Ubuntu-specific Home Manager configuration

### Module Organization
Modules are organized by scope and functionality:

**NixOS modules** (`modules/nixos/`): System-level configuration
- `audio.nix`, `boot.nix`, `desktop.nix`, `docker.nix`, `firewall.nix`
- `locale.nix`, `nvidia.nix`, `printing.nix`, `tailscale.nix`, `time.nix`, `user.nix`

**Home Manager modules** (`modules/home-manager/`):
- `cli/`: CLI tools and programs (neovim, tmux, git, ai tools)
  - Configuration files are colocated with module definitions (e.g., `cli/nvim/`, `cli/.tmux.conf`)
- `gui/`: GUI applications and window managers (hyprland, waybar, terminals: alacritty, kitty, wezterm, ghostty)
  - Configuration files are colocated with module definitions (e.g., `gui/waybar/`, `gui/hyprland/`, `gui/wezterm/`)
- `shell/`: Shell configurations (fish, bash, nu, starship, aliases, variables)
  - Configuration files are colocated with module definitions (e.g., `shell/starship/`)
- `lang/`: Language-specific tooling (clang, javascript, lua, nixlang, tsx)
- `scripts/`: Custom scripts as Nix packages (see below)

**Custom packages** (`modules/custom/`):
- `commiter.nix`: Custom Go tool from github.com/Hugo0Vaz/commiter
- `propener.nix`: PR opener tool from github.com/Hugo0Vaz/pr-opener

## Common Commands

### System Management Scripts
The repository includes three main scripts defined in `modules/home-manager/scripts/`:

**Update flake inputs:**
```bash
updateSystem              # Update all flake inputs
updateSystem -i nixpkgs   # Update specific input
```

**Rebuild NixOS system** (for NixOS hosts):
```bash
rebuildSystem
```
- Must be run from the flake directory
- Auto-detects hostname for flake target
- Handles git staging/committing
- Uses `nix-output-monitor` (nom) for better output
- Auto-commits with generation info on success

**Rebuild Home Manager** (for standalone Home Manager or testing):
```bash
rebuildHome
```
- Auto-detects available configurations
- Supports multiple naming patterns (username, hostname, combinations)
- Warns if running on NixOS (suggests using `rebuildSystem` instead)

### Standard Nix Commands

**Check flake structure:**
```bash
nix flake show
nix flake metadata
```

**Build specific configuration without switching:**
```bash
# NixOS configuration
nixos-rebuild build --flake .#nixos-workstation

# Home Manager configuration
nix build .#homeConfigurations.wsl.activationPackage
```

**Test flake evaluation:**
```bash
nix flake check
```

**Manual rebuild commands:**
```bash
# NixOS (requires sudo)
sudo nixos-rebuild switch --flake .#nixos-workstation

# Home Manager (standalone)
home-manager switch --flake .#wsl
home-manager switch --flake .#ubuntu
```

## Development Workflow

### Adding New Hosts
1. Create host directory: `hosts/<hostname>/`
2. For NixOS: Create `configuration.nix` and `home.nix`
3. For non-NixOS: Create `home.nix` only
4. Add host to `flake.nix`:
   - NixOS hosts: Add to `nixosConfigurations`
   - Non-NixOS: Add to `homeConfigurations`

### Creating New Modules
1. Place module in appropriate directory:
   - System-level: `modules/nixos/<name>.nix`
   - User-level: `modules/home-manager/<category>/<name>.nix`
2. Configuration files should be colocated with their module:
   - Place config files in a subdirectory next to the module (e.g., `gui/wezterm/wezterm.lua` alongside `gui/wezterm.nix`)
   - Reference config files using relative paths (e.g., `source = ./wezterm/wezterm.lua`)
3. Import module in:
   - NixOS modules: `hosts/<hostname>/configuration.nix`
   - Home Manager modules: Update category's `default.nix` or directly in `home.nix`

### Custom Scripts
Scripts are packaged using `pkgs.writeShellScriptBin` in `modules/home-manager/scripts/`:
- Each script is a separate .nix file exporting a shell script
- Scripts are imported via `scripts/default.nix`
- Available utilities: cowsay, jq, git, nix-output-monitor, home-manager

### Custom Go Packages
Custom Go tools (commiter, propener) use `pkgs.buildGoModule`:
- Specify `pname`, `version`, `src` (GitHub), and `vendorHash`
- Import using `callPackage` in system packages
- Located in `modules/custom/`

## Key Configuration Details

### User Configuration
- Primary user: `hugomvs` (NixOS workstation)
- Default shell: fish
- User groups: networkmanager, wheel

### GUI Environment
- Window Manager: Hyprland
- Status bar: Waybar
- Application launcher: Wofi
- Notification daemon: Dunst
- Multiple terminal options: Alacritty, Kitty, Wezterm, Ghostty

### System Features
- Desktop environment: GNOME Shell (with GSK_RENDERER=ngl workaround)
- Graphics: NVIDIA support configured
- Audio: PipeWire/PulseAudio
- Container runtime: Docker
- VPN: Tailscale
- Boot: Systemd-boot

## Important Notes

### Flake Configuration
- Experimental features required: `nix-command`, `flakes`
- Unfree packages allowed: `nixpkgs.config.allowUnfree = true`
- State version: 24.05 (both system and Home Manager)

### Git Integration
- Scripts automatically handle git operations
- Rebuild scripts offer to stage and commit changes
- Commit messages include generation info

### Home Manager Integration
- NixOS workstation: Home Manager integrated with system config (nixosModules.home-manager)
- File conflicts: Backup extension set to `.bkp`
- Global pkgs enabled: Shares nixpkgs with system
