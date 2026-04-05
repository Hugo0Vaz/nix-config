# AGENTS.md

This repo is a Nix flake for NixOS + Home-Manager, organized via flake-parts and `import-tree ./modules`.

## Ground Rules For Agents
- Prefer commands that do NOT mutate the machine. Avoid `sudo nixos-rebuild switch` unless explicitly requested.
- Do not add/commit secrets. This repo uses `pass` for tokens in shell aliases; do not inline tokens into files.
- Avoid touching host-specific credentials (e.g., `users.users.*.initialPassword`) unless explicitly asked.
- Cursor/Copilot rules: none found (`.cursor/rules/`, `.cursorrules`, `.github/copilot-instructions.md`). If these appear later, follow them.

## Quick Start
- Enter dev shell (includes `nixpkgs-fmt`, `stylua`, `nil`, `lua-language-server`, `just`): `nix develop`
- List `just` recipes: `just --list`
- Discover flake outputs without writing lockfiles: `nix flake show --all-systems --no-write-lock-file`

## Build / Lint / Test
This repo has no conventional unit test suite. "Test" usually means Nix evaluation/build checks.

### Run All Checks
- `just check` (runs `nix flake check`)
- More debug output:
  - `nix flake check -L --show-trace --no-write-lock-file`
- If you want to see everything that would run:
  - `nix flake show --all-systems --no-write-lock-file`

### Run A Single Check (Single "Test" Equivalent)
Prefer building one attribute to validate changes quickly.

- Build the NixOS system closure (no activation):
  - `nix build .#nixosConfigurations.nixos-notebook.config.system.build.toplevel -L --no-write-lock-file`
- Build the NixOS VM (useful for boot/runtime sanity without switching your host):
  - `nix build .#nixosConfigurations.nixos-notebook.config.system.build.vm -L --no-write-lock-file`
  - Then run: `./result/bin/run-nixos-vm`
- Evaluate a single value (fast feedback):
  - `nix eval .#nixosConfigurations.nixos-notebook.config.networking.hostName --raw --no-write-lock-file`
- Evaluate with more context (when a value fails due to missing args):
  - `nix eval -L --show-trace --no-write-lock-file .#nixosConfigurations.nixos-notebook.config.system.stateVersion --raw`
- Quick sanity on dev shell evaluation:
  - `nix develop -c true --no-write-lock-file`

### Rebuild / Activate (Mutating)
Only when explicitly asked to apply changes to the machine:
- `just rebuild-test` (temporary activation; lower risk than switch)
- `just rebuild-switch` (persists on the running system)

If you must run `nixos-rebuild` directly:
- `nixos-rebuild test --flake .#nixos-notebook`
- `sudo nixos-rebuild switch --flake .#nixos-notebook`

### Common Just Recipes
From `justfile`:
- `just rebuild-vm nixos-notebook` (produces VM build artifacts)
- `just clean` (removes `./result`, `./*.qcow2`, `./nixos-switch.log`)

### Updating Inputs (Mutating)
- Update a single input: `nix flake lock --update-input nixpkgs`
- Update everything: `nix flake update`

## Formatting / Linting
No `formatter` output is defined in the flake, so `nix fmt` is not configured.

- Format Nix:
  - `nixpkgs-fmt $(git ls-files '*.nix')`
- Format Neovim Lua:
  - `stylua modules/dotfiles/nvim`

Tip: if you want a non-destructive "check", run the formatter and inspect `git diff`.

## Repo Structure (Where Things Live)
- Flake entrypoint: `flake.nix` delegates to flake-parts + `import-tree ./modules`.
- Systems list: `modules/flake-parts.nix`.
- Flake outputs (host list): `modules/hosts/hosts.nix`.
- Host module: `modules/hosts/nixos-notebook/configuration.nix`.
- Host hardware module: `modules/hosts/nixos-notebook/hardware.nix`.
- Aspects: `modules/aspects/*.nix`.
  - Each aspect typically defines both `flake.modules.nixos.<aspect>` and `flake.modules.homeManager.<aspect>`.
  - NixOS aspects usually wire their HM counterpart via:
    - `home-manager.sharedModules = [ inputs.self.modules.homeManager.<aspect> ];`
- Dotfiles: `modules/dotfiles/` (notably `modules/dotfiles/nvim`).
- Packaged helper scripts: `modules/_scripts/*.nix` (usually `pkgs.writeShellScriptBin`).

## Common Edits
- Add an aspect:
  - Create `modules/aspects/<name>.nix` defining `flake.modules.nixos.<name>` and (usually) `flake.modules.homeManager.<name>`.
  - Add the NixOS module to `modules/hosts/nixos-notebook/configuration.nix` imports.
- Add a new host:
  - Create `modules/hosts/<host>/configuration.nix` (+ `hardware.nix` if needed).
  - Add it to `modules/hosts/hosts.nix` under `flake.nixosConfigurations`.
  - Keep host names consistent with `networking.hostName`.

## Code Style Guidelines

### Nix
- Formatting: use `nixpkgs-fmt` (2-space indentation; do not hand-align).
- Imports:
  - In host configs, keep `imports = [ ... ]` explicit and stably ordered (hardware/base -> aspects -> `inputs.home-manager.nixosModules.home-manager`).
  - In aspects, keep `home-manager.sharedModules` near the top so the NixOS/HM linkage is obvious.
  - Avoid duplicate imports when touching a module (e.g., `inputs.home-manager.nixosModules.home-manager` should usually be imported once).
- Naming:
  - Aspect filenames and module names: kebab-case (e.g., `cli-tools.nix` -> `flake.modules.nixos.cli-tools`).
  - Host modules: `flake.modules.nixos.nixosNotebookConfiguration` / `flake.modules.nixos.nixosNotebookHardwareConfiguration` (CamelCase suffixes are fine for host-specific modules).
- Types / options (when writing real NixOS/HM modules):
  - Use `lib.mkOption` with `type = lib.types.*` and clear `description`.
  - Prefer `lib.mkEnableOption` for feature toggles.
- Option patterns:
  - Prefer `lib.mkDefault` for host defaults that should be overrideable.
  - Prefer `lib.mkIf`/`lib.mkMerge` over deep conditional nesting.
  - Prefer small, composable aspects over one huge module.
- Expression conventions:
  - Prefer `inherit (pkgs) foo bar;` over repeating `pkgs.foo`.
  - Use `with pkgs; [ ... ]` only in small scopes (packages lists), not at top-level.
  - Keep lists and attrsets stably ordered; avoid churn-only reorders.
- Error handling:
  - Prefer early failure with clear messages (`assert`, `throw`) for non-optional behavior.
  - Avoid `builtins.trace` in committed code; use it only for temporary diagnosis.
  - If something is host-specific, gate it behind the host module instead of hardcoding into an aspect.

### Home-Manager In This Repo
- Home-Manager is used as a NixOS module (`inputs.home-manager.nixosModules.home-manager`), not as a standalone `homeConfigurations.*` output.
- Prefer sharing HM configuration through `home-manager.sharedModules` from aspects instead of writing user config directly in the host.
- Avoid making assumptions about usernames/home directories; keep defaults overrideable with `lib.mkDefault`.

### Shell Scripts Packaged In Nix
- Location: `modules/_scripts/*.nix`.
- Pattern: `pkgs.writeShellScriptBin "name" '' ... ''`.
- Keep scripts POSIX-ish unless you intentionally rely on bash; add safety flags (`set -euo pipefail`) when reasonable.
- Do not bake secrets into scripts; keep `pass` usage in interactive shell aliases only.

### Lua (Neovim)
- Location: `modules/dotfiles/nvim`.
- Formatter: `stylua modules/dotfiles/nvim` (config: `modules/dotfiles/nvim/.stylua.toml`).
- Conventions:
  - Use `local` for variables.
  - Plugin specs live in `modules/dotfiles/nvim/lua/plugins/` and return a table: `return { ... }`.
  - Keep plugin config self-contained per file; avoid mega "plugins.lua" files.
  - Keymaps should use `vim.keymap.set` and include `desc = ...` when user-facing.
  - Use `pcall(require, ...)` when depending on optional plugins.
  - Use `---@diagnostic` directives sparingly and locally.
  - Prefer `vim.api.nvim_create_autocmd` + augroups over legacy `vim.cmd` autocmd blocks.

### General Hygiene
- Keep changes small and localized; avoid large reorder-only diffs.
- Do not commit credentials; keep `pass ...` references as-is.
- Prefer non-mutating verification (`nix build`/`nix eval`) before any `nixos-rebuild` activation.
- Default to ASCII in new/edit content unless the file already uses Unicode.

## When In Doubt (Safe Defaults)
- Validate: `nix flake check -L --show-trace --no-write-lock-file`
- Fastest signal: `nix build .#nixosConfigurations.nixos-notebook.config.system.build.toplevel -L --no-write-lock-file`
- Format before finalizing: `nixpkgs-fmt $(git ls-files '*.nix')` and `stylua modules/dotfiles/nvim`
