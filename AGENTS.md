# AGENTS.md

This repo is a Nix flake for NixOS + Home-Manager, organized via flake-parts and `import-tree ./modules`.

## Ground Rules For Agents
- Prefer commands that do NOT mutate the machine. Avoid `sudo nixos-rebuild switch` unless explicitly requested.
- Do not add/commit secrets. This repo references `pass` for tokens in shell aliases; do not inline tokens into files.
- No Cursor/Copilot instruction files were found (`.cursor/rules/`, `.cursorrules`, `.github/copilot-instructions.md`).

## Quick Start
- Enter dev shell (includes `nixpkgs-fmt`, `stylua`, `nil`, `lua-language-server`, `just`):
  - `nix develop`
- List available `just` recipes:
  - `just --list`

## Common Commands (Just)
From `justfile`:
- Flake checks:
  - `just check`  # runs `nix flake check`
- NixOS (mutating; uses your current hostname):
  - `just rebuild-switch`  # `sudo nixos-rebuild switch --flake .#$(hostname)`
  - `just rebuild-test`    # `nixos-rebuild test --flake .#$(hostname)`
- NixOS VM build (non-mutating, but produces build artifacts):
  - `just rebuild-vm nixos-workstation`
  - `just rebuild-vm nixos-notebook`
- Home Manager (mutating; expects flake key to match username):
  - `just home-switch`  # `home-manager switch -b bkp --flake .#$(whoami)`
  - Note: this repo defines `homeConfigurations.hugom` for WSL (`modules/hosts/_wsl/home.nix`).

## Nix Flake: Targets You Can Build
Configured in `modules/hosts/hosts.nix`:
- NixOS:
  - `.#nixosConfigurations.nixos-workstation`
  - `.#nixosConfigurations.nixos-notebook`
- Home-Manager standalone:
  - `.#homeConfigurations.hugom`

## Build / Lint / Test (Repo Reality)
There is no conventional unit test suite here; “test” typically means:
- `nix flake check` (evaluation/build checks)
- building specific attributes (NixOS system closure / HM activation package)
- formatting (`nixpkgs-fmt`, `stylua`) and basic sanity via evaluation

### Run All Checks
- `nix flake check`
- With better error context:
  - `nix flake check --show-trace`

### Run A Single Check / Single Test Equivalent
Prefer building one attribute (fastest targeted signal):
- Build NixOS system closure (no switch):
  - `nix build .#nixosConfigurations.nixos-workstation.config.system.build.toplevel`
  - `nix build .#nixosConfigurations.nixos-notebook.config.system.build.toplevel`
- Build Home-Manager activation package:
  - `nix build .#homeConfigurations.hugom.activationPackage`

If you need to evaluate a single value (fast feedback):
- `nix eval .#nixosConfigurations.nixos-workstation.config.networking.hostName`
- `nix eval .#homeConfigurations.hugom.config.home.username`

### Rebuild (Mutating)
Only when explicitly asked to apply changes to the machine:
- `sudo nixos-rebuild switch --flake .#nixos-workstation`
- `sudo nixos-rebuild switch --flake .#nixos-notebook`
- `home-manager switch -b bkp --flake .#hugom`

### Formatting
No `formatter` output is defined in the flake, so `nix fmt` is NOT configured.
Use the tools provided by the dev shell (`modules/dev-shell.nix`).

- Format Nix:
  - `nixpkgs-fmt $(git ls-files '*.nix')`
- Format Neovim Lua (uses `modules/dotfiles/nvim/.stylua.toml`):
  - `stylua modules/dotfiles/nvim`

## Repo Structure (How To Add/Change Things)
- Flake entrypoint: `flake.nix` delegates to flake-parts + `import-tree ./modules`.
- Flake-parts systems list: `modules/flake-parts.nix`.
- Hosts:
  - `modules/hosts/hosts.nix` defines `nixosConfigurations` + `homeConfigurations`.
  - `modules/hosts/_<host>/configuration.nix` selects “aspects” (modules).
  - `modules/hosts/_<host>/home.nix` selects Home-Manager modules for that host.
- “Aspects” live in `modules/aspects/*.nix` and typically define both:
  - `flake.modules.nixos.<name>`
  - `flake.modules.homeManager.<name>`

## Code Style Guidelines

### Nix Style
- Formatter: `nixpkgs-fmt` (use it; don’t hand-align).
- Indentation: 2 spaces; keep attribute sets tidy; minimize diff churn.
- Module shape used throughout `modules/aspects/*.nix`:
  - Define `flake.modules.nixos.<aspect> = { inputs, pkgs, ... }: { ... };`
  - Define `flake.modules.homeManager.<aspect> = { pkgs, ... }: { ... };`
  - For NixOS modules that “enable” HM parts, use:
    - `home-manager.sharedModules = [ inputs.self.modules.homeManager.<aspect> ];`
- Naming:
  - Aspect names: kebab-case consistent with filenames (e.g. `cli-tools`, `local-time`).
  - Host folders: `modules/hosts/_nixos-workstation`, `modules/hosts/_nixos-notebook`, `modules/hosts/_wsl`.
- Imports:
  - Prefer explicit `imports = [ inputs.self.modules.nixos.<x> ... ];` in host configs.
  - Keep imports grouped by purpose; keep ordering stable to reduce churn.
- Error handling:
  - Prefer early failure with clear messages (`assert`, `throw`) when adding non-optional behavior.
  - Avoid `builtins.trace` in committed code unless diagnosing a hard evaluation issue.

### Lua (Neovim) Style
- Location: `modules/dotfiles/nvim`.
- Formatter: `stylua` with `modules/dotfiles/nvim/.stylua.toml`:
  - `indent_width = 2`, `column_width = 160`, prefer single quotes, no call parentheses.
- Conventions:
  - Use `local` for variables; keep plugin specs as `return { ... }`.
  - Prefer `pcall(require, ...)` when depending on optional plugins/modules.
  - Use `---@diagnostic disable-next-line` or type annotations sparingly and locally.
- Naming:
  - Files in `modules/dotfiles/nvim/lua/plugins/` should match the feature/plugin they configure.
  - Keymaps should include `desc = ...` for discoverability.

### Imports / Ordering (General)
- Keep changes small and localized.
- Don’t reorder large lists unless needed (formatters already normalize whitespace).

### Security / Secrets
- Shell aliases reference `pass` entries for API keys (`modules/aspects/aliases.nix`).
- Do not replace `pass ...` with raw tokens; do not commit credentials or machine-specific secrets.

## When In Doubt (Safe Defaults)
- Validate with: `nix flake check --show-trace`
- For one-target verification: build the specific host closure or HM activation package.
- Format before finalizing: `nixpkgs-fmt ...` and `stylua ...`
