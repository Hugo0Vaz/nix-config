# AGENTS.md

This repo is a Nix flake for NixOS + Home-Manager, organized via flake-parts and `import-tree ./modules`.

## Ground Rules (Read First)
- Prefer non-mutating commands. Avoid `sudo nixos-rebuild switch` unless explicitly requested.
- Do not add/commit secrets. Keep `pass ...` references as-is; never inline tokens/keys.
- Avoid touching host-specific credentials (e.g., `users.users.*.initialPassword`) unless explicitly asked.
- Cursor/Copilot rules:
  - No Cursor rules found (`.cursor/rules/`, `.cursorrules`).
  - No Copilot rules found (`.github/copilot-instructions.md`).

## Quick Start
- Enter dev shell (includes `just`, `nixpkgs-fmt`, `stylua`, `nil`, `lua-language-server`): `nix develop`
- List repo commands: `just --list`
- Inspect flake outputs (no lockfile write): `nix flake show --all-systems --no-write-lock-file`

## Build / Lint / Test
This repo has no conventional unit tests. “Tests” are Nix eval/build checks.

### Run All Checks
- `just check` (runs `nix flake check`)
- Verbose diagnostics (recommended when debugging):
  - `nix flake check -L --show-trace --no-write-lock-file`

### Run A Single Check (Single “Test” Equivalent)
Prefer building/evaluating one attribute for fast feedback.

- Build a system closure (no activation):
  - `nix build .#nixosConfigurations.nixos-notebook.config.system.build.toplevel -L --no-write-lock-file`
  - `nix build .#nixosConfigurations.nixos-server.config.system.build.toplevel -L --no-write-lock-file`
- Build a VM (boot sanity without switching your host):
  - `nix build .#nixosConfigurations.nixos-notebook.config.system.build.vm -L --no-write-lock-file`
  - Run it: `./result/bin/run-nixos-vm`
- Evaluate a single value (fastest signal):
  - `nix eval .#nixosConfigurations.nixos-notebook.config.networking.hostName --raw --no-write-lock-file`
  - `nix eval .#nixosConfigurations.nixos-server.config.services.openssh.enable --raw --no-write-lock-file`
- Evaluate with trace (when evaluation fails):
  - `nix eval -L --show-trace --no-write-lock-file .#nixosConfigurations.nixos-notebook.config.system.stateVersion --raw`
- Dev shell eval smoke test:
  - `nix develop -c true --no-write-lock-file`

### Rebuild / Activate (Mutating)
Only use these when the user explicitly wants to apply changes.

- `just rebuild-test` (temporary activation; runs `nixos-rebuild test --flake .#$(hostname)`)
- `just rebuild-switch` (persistent activation; uses sudo)
- Remote deploy (passwordless root SSH):
  - `just remote-switch root@<host> config=nixos-server`

### Updating Inputs (Mutating)
- Update nixpkgs only: `nix flake lock --update-input nixpkgs`
- Update all inputs: `nix flake update`

## Formatting / Linting
No `formatter` output is defined in the flake; `nix fmt` is not configured.

- Format Nix:
  - `nixpkgs-fmt $(git ls-files '*.nix')`
- Format Neovim Lua:
  - `stylua modules/dotfiles/nvim`

Tip: run formatters, then inspect `git diff` before committing.

## Repo Structure (Where Things Live)
- Flake entrypoint: `flake.nix` (flake-parts + `import-tree ./modules`).
- Systems list: `modules/flake-parts.nix`.
- Host outputs: `modules/hosts/hosts.nix`.
- Host configs:
  - `modules/hosts/nixos-notebook/configuration.nix` + `modules/hosts/nixos-notebook/hardware.nix`
  - `modules/hosts/nixos-server/configuration.nix` + `modules/hosts/nixos-server/hardware-configuration.nix`
- Aspects (reusable modules): `modules/aspects/*.nix`.
  - Typically define `flake.modules.nixos.<aspect>` and `flake.modules.homeManager.<aspect>`.
  - NixOS aspects often wire HM via `home-manager.sharedModules`.
- Dotfiles: `modules/dotfiles/` (notably `modules/dotfiles/nvim`).
- Packaged helper scripts: `modules/_scripts/*.nix` (`pkgs.writeShellScriptBin`).

## Code Style Guidelines

### Nix (NixOS + Home-Manager modules)
- Formatting: use `nixpkgs-fmt` (2-space indentation; don’t hand-align).
- Imports:
  - Keep `imports = [ ... ]` explicit and stably ordered (hardware/base -> aspects -> HM module).
  - Avoid duplicate imports (especially `inputs.home-manager.nixosModules.home-manager`).
  - In aspects, keep `home-manager.sharedModules` near the top so NixOS/HM linkage is obvious.
- Naming:
  - Aspect filenames and module names: kebab-case (e.g. `cli-tools.nix` -> `flake.modules.nixos.cli-tools`).
  - Host modules may use CamelCase suffixes (host-specific).
- Options/types:
  - Prefer `lib.mkEnableOption` for toggles.
  - Use `lib.mkOption` with `type = lib.types.*` and a clear `description`.
- Option composition:
  - Prefer `lib.mkDefault` for overrideable host defaults.
  - Prefer `lib.mkIf` / `lib.mkMerge` over deep nesting.
  - Keep modules small and composable (aspects).
- Expression conventions:
  - Prefer `inherit (pkgs) foo bar;` over repeating `pkgs.foo`.
  - Use `with pkgs; [ ... ]` only in small local scopes.
  - Keep lists/attrsets stably ordered; avoid churn-only reorders.
- Error handling:
  - Fail early with a clear message (`assert`, `throw`) for required invariants.
  - Don’t commit `builtins.trace` (use only for temporary diagnosis).
  - If behavior is host-specific, gate it in the host module instead of hardcoding into an aspect.

### Home-Manager (In This Repo)
- HM is used as a NixOS module (`inputs.home-manager.nixosModules.home-manager`), not as standalone `homeConfigurations.*`.
- Prefer sharing HM config via `home-manager.sharedModules` from aspects.
- Don’t assume usernames/home dirs; keep defaults overrideable with `lib.mkDefault`.

### Shell Scripts Packaged In Nix
- Location: `modules/_scripts/*.nix`.
- Pattern: `pkgs.writeShellScriptBin "name" '' ... ''`.
- Keep scripts POSIX-ish unless intentionally bash; add `set -euo pipefail` when appropriate.
- Never bake secrets into scripts; keep secret access interactive (`pass`, `sops`, etc.).

### Lua (Neovim)
- Location: `modules/dotfiles/nvim`.
- Format: `stylua modules/dotfiles/nvim` (see `modules/dotfiles/nvim/.stylua.toml`).
- Conventions:
  - Use `local` for variables; avoid globals.
  - Plugin specs live in `modules/dotfiles/nvim/lua/plugins/` and return a table.
  - Keep plugin config self-contained; avoid mega plugin files.
  - Keymaps use `vim.keymap.set` and include `desc = ...` for user-facing bindings.
  - Use `pcall(require, ...)` for optional dependencies.

## When In Doubt (Safe Defaults)
- `nix flake check -L --show-trace --no-write-lock-file`
- `nix build .#nixosConfigurations.nixos-notebook.config.system.build.toplevel -L --no-write-lock-file`
- `nixpkgs-fmt $(git ls-files '*.nix')` and `stylua modules/dotfiles/nvim`
