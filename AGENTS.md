# AGENTS.md

This repo is a Nix flake for NixOS + Home-Manager, organized via flake-parts and `import-tree ./modules`.

## Ground Rules (Read First)
- Prefer non-mutating commands. Avoid `sudo nixos-rebuild switch` unless explicitly requested.
- Do not add/commit secrets. Keep `pass ...` references as-is; never inline tokens/keys.
- Avoid touching host-specific credentials (e.g., `users.users.*.initialPassword`) unless explicitly asked.
- `import-tree` discovers modules from the git index — **always `git add` new files** (e.g., new aspects, scripts, dotfiles) before running `nix flake check`, `nix build`, or `nix eval`, otherwise the new module will not be found.
- Cursor/Copilot rules:
  - No Cursor rules found (`.cursor/rules/`, `.cursorrules`).
  - No Copilot rules found (`.github/copilot-instructions.md`).

## Quick Start
- Enter dev shell (includes `just`, `nixpkgs-fmt`, `stylua`, `nil`, `lua-language-server`): `nix develop`
- List repo commands: `just --list`
- Inspect flake outputs (no lockfile write): `nix flake show --all-systems --no-write-lock-file`

## Build / Lint / Test
This repo has no conventional unit tests. "Tests" are Nix eval/build checks.

### Run All Checks
- `just check` (runs `nix flake check`)
- Verbose diagnostics (recommended when debugging):
  - `nix flake check -L --show-trace --no-write-lock-file`

### Run A Single Check (Single "Test" Equivalent)
Prefer building/evaluating one attribute for fast feedback.

- Build a NixOS system closure (no activation) — replace `<host>` with any NixOS host:
  - `nix build .#nixosConfigurations.<host>.config.system.build.toplevel -L --no-write-lock-file`
  - Examples: `nixos-notebook`, `nixos-server`, `nixos-kot225`, `nixos-workstation`
- Build a standalone Home-Manager activation (for `kot225wsl`):
  - `nix build .#homeConfigurations."hugom@kot225".activationPackage -L --no-write-lock-file`
- Build a VM (boot sanity without switching your host):
  - `nix build .#nixosConfigurations.<host>.config.system.build.vm -L --no-write-lock-file`
  - Run it: `./result/bin/run-nixos-vm`
- Evaluate a single value (fastest signal):
  - `nix eval .#nixosConfigurations.<host>.config.networking.hostName --raw --no-write-lock-file`
  - `nix eval .#nixosConfigurations.<host>.config.services.openssh.enable --raw --no-write-lock-file`
- Evaluate with trace (when evaluation fails):
  - `nix eval -L --show-trace --no-write-lock-file .#nixosConfigurations.<host>.config.system.stateVersion --raw`
- Dev shell eval smoke test:
  - `nix develop -c true --no-write-lock-file`

### Rebuild / Activate (Mutating)
Only use these when the user explicitly wants to apply changes.

- `just rebuild-test` (temporary NixOS activation; runs `nixos-rebuild test --flake .#$(hostname)`)
- `just rebuild-switch` (persistent NixOS activation; uses sudo)
- `just home-switch` (standalone Home-Manager activation for the current user/host)
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
- Dev shell: `modules/dev-shell.nix`.
- Host outputs: each host has its own `modules/hosts/<host>/default.nix` defining either `flake.nixosConfigurations` or `flake.homeConfigurations`.
- NixOS host configs (`configuration.nix` + `hardware-configuration.nix`):
  - `modules/hosts/nixos-notebook/`
  - `modules/hosts/nixos-server/`
  - `modules/hosts/nixos-kot225/`
  - `modules/hosts/nixos-workstation/`
- Standalone Home-Manager host (`home.nix`):
  - `modules/hosts/kot225wsl/`
- Aspects (reusable modules): `modules/aspects/*.nix`.
  - Typically define `flake.modules.nixos.<aspect>` and `flake.modules.homeManager.<aspect>`.
  - NixOS aspects often wire HM via `home-manager.sharedModules`.
- Dotfiles: `modules/dotfiles/`.
  - `btop`, `dms`, `dunst`, `ghostty`, `glance`, `kitty`, `niri`, `noctalia`, `nvim`, `pi`, `starship`, `tmux`, `waybar`, `wofi`
- Packaged helper scripts: `modules/_scripts/*.nix` (`pkgs.writeShellScriptBin`).
  - `clone-tree.nix`, `couchdb-obsidian-livesync-bootstrap.nix`, `nix-config-sync-check.nix`, `secret-manager.nix`, `spawn-tmux.nix`
- Assets: `modules/assets/` (images, wallpapers).
- Secrets: `secrets/secrets.yaml` (encrypted via `sops-nix`, config in `.sops.yaml`).
- Docs: `docs/` (misc notes, e.g. `system-reminder.md`).

## Pi Agent Self-Editing (Extensions, Skills, Config)
The pi agent's dotfiles live in `modules/dotfiles/pi/`. Home-Manager creates a
live, out-of-store symlink at `~/.pi` → `modules/dotfiles/pi/`, so pi reads its
runtime config directly from the repo at all times — no rebuild is needed for
config changes to take effect.

### How to edit pi's own config
- **Extensions**: edit files under `modules/dotfiles/pi/agent/extensions/`.
  - Current extensions: `guardrails-bash.ts`, `guardrails-privacy.ts`,
    `guardrails-readonly.ts`, `guardrails-write-scope.ts`, `notify.ts`.
- **Settings**: edit `modules/dotfiles/pi/agent/settings.json`.
- **Models**: edit `modules/dotfiles/pi/agent/models.json`.
- **Skills**: if added, place them under `modules/dotfiles/pi/agent/skills/`.

Changes take effect on the next pi invocation (or conversation turn) because
`~/.pi` is a live symlink. Do **not** edit `~/.pi` directly — always target
`modules/dotfiles/pi/` so changes stay tracked in git.

## Code Style Guidelines

### Nix (NixOS + Home-Manager modules)
- Formatting: use `nixpkgs-fmt` (2-space indentation; don't hand-align).
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
  - Don't commit `builtins.trace` (use only for temporary diagnosis).
  - If behavior is host-specific, gate it in the host module instead of hardcoding into an aspect.

### Home-Manager (In This Repo)
- HM is primarily wired as a NixOS module via `inputs.home-manager.nixosModules.home-manager`.
  - Prefer sharing HM config via `home-manager.sharedModules` from aspects.
- One standalone `homeConfigurations` entry exists: `kot225wsl` (WSL, no NixOS).
  - Defined in `modules/hosts/kot225wsl/default.nix`, config in `modules/hosts/kot225wsl/home.nix`.
- Don't assume usernames/home dirs; keep defaults overrideable with `lib.mkDefault`.

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
- `nix build .#homeConfigurations."hugom@kot225".activationPackage -L --no-write-lock-file`
- `nixpkgs-fmt $(git ls-files '*.nix')` and `stylua modules/dotfiles/nvim`
