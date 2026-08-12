# nix-config

Nix flake for NixOS + Home-Manager, organized via flake-parts and `import-tree ./modules`.

## Quick Start

```sh
nix develop            # dev shell: just, nixpkgs-fmt, stylua, nil, lua-language-server
just --list            # list recipes
just check             # run eval/build checks (nix flake check)
```

## Install

### NixOS

```sh
git clone git@github.com:Hugo0Vaz/nix-config.git && cd nix-config

# build/test first (non-mutating)
nix build .#nixosConfigurations.nixos-notebook.config.system.build.toplevel -L --no-write-lock-file

# activate (mutating)
sudo nixos-rebuild switch --flake .#nixos-notebook
# or via just:  just rebuild-test  |  just rebuild-switch
```

Hosts: `nixos-notebook`, `nixos-server`, `nixos-kot225`, `nixos-workstation`.

### Non-NixOS (Home-Manager standalone)

```sh
git clone git@github.com:Hugo0Vaz/nix-config.git && cd nix-config

# install HM if needed
nix run home-manager/master -- init --switch

# activate (WSL example)
home-manager switch --flake .#hugom@kot225
```

Template: `modules/hosts/kot225wsl/`.

## Repo Layout

- `flake.nix` — entrypoint (flake-parts + import-tree)
- `modules/hosts/` — host configs (NixOS + standalone Home-Manager)
- `modules/aspects/` — reusable NixOS/HM modules, wired via `home-manager.sharedModules`
- `modules/dotfiles/` — managed dotfiles (Neovim, pi agent, etc.)
- `modules/_scripts/` — packaged helper scripts

## Adding a Host

Copy an existing host as a template (`modules/hosts/nixos-notebook/` for NixOS, `modules/hosts/kot225wsl/` for standalone HM), then:

1. Create `modules/hosts/<host>/` with `configuration.nix` + `hardware.nix` (NixOS) or `home.nix` (HM), plus a `default.nix` that exports `flake.nixosConfigurations` or `flake.homeConfigurations`.
2. Generate hardware config on the target machine: `sudo nixos-generate-config --show-hardware-config`.
3. Verify without switching:

```sh
nix build .#nixosConfigurations.<host>.config.system.build.toplevel -L --no-write-lock-file   # NixOS
home-manager switch --flake .#<user>@<host>                                                   # HM
```

Keep `flake.nixosConfigurations.<host>` consistent with `networking.hostName` (`just rebuild-switch` uses `.#$(hostname)`).

## Formatting

```sh
nixpkgs-fmt $(git ls-files '*.nix')
stylua modules/dotfiles/nvim
```

## Notes

- Secrets: keep `pass ...` references as-is; never commit tokens/credentials.
- Prefer `nix build`/`nix eval` before `nixos-rebuild switch`.
- `import-tree` discovers modules from the git index — `git add` new files before `nix flake check`/`nix build`.
