# nix-config

Nix flake for NixOS + Home-Manager, organized via flake-parts and `import-tree ./modules`.

## Quick Start

```sh
# enter dev shell (just, nixpkgs-fmt, stylua, nil, lua-language-server, ...)
nix develop

# list available recipes
just --list

# run repo checks (evaluation/build checks)
just check
```

## Install (NixOS)

1. Clone the repo (location does not matter).

```sh
git clone git@github.com:Hugo0Vaz/nix-config.git
cd nix-config
```

2. Build/test first (non-mutating).

```sh
nix flake check -L --show-trace --no-write-lock-file
nix build .#nixosConfigurations.nixos-notebook.config.system.build.toplevel -L --no-write-lock-file
```

3. Activate (mutating).

```sh
# this repo currently defines: nixosConfigurations.nixos-notebook
sudo nixos-rebuild switch --flake .#nixos-notebook

# or via just (targets current hostname)
just rebuild-test
just rebuild-switch
```

## Home-Manager

Home-Manager is used via the NixOS module (`inputs.home-manager.nixosModules.home-manager`), not as a standalone `homeConfigurations.*` output.

Update user config through aspects in `modules/aspects/*.nix` (wired via `home-manager.sharedModules`) and rebuild NixOS.

## Repo Layout

- `flake.nix`: flake entrypoint
- `modules/hosts/hosts.nix`: flake outputs (`nixosConfigurations`)
- `modules/hosts/nixos-notebook/configuration.nix`: host imports (aspects)
- `modules/aspects/*.nix`: composable NixOS/HM modules
- `modules/dotfiles/`: managed dotfiles (notably Neovim)
- `modules/_scripts/*.nix`: packaged helper scripts (`pkgs.writeShellScriptBin`)

## Adding A New Host

This repo models each host as a flake module under `modules/hosts/<host>/` and exposes it via `modules/hosts/hosts.nix`.

1. Create a host directory:

```sh
mkdir -p modules/hosts/<host>
```

2. Add `modules/hosts/<host>/hardware.nix` (optional but recommended).

If you are on the target machine, you can generate this and then copy the relevant parts:

```sh
sudo nixos-generate-config --show-hardware-config
```

3. Add `modules/hosts/<host>/configuration.nix`.

Use the existing host as a template (`modules/hosts/nixos-notebook/configuration.nix`). Minimal skeleton:

```nix
{
  flake.modules.nixos.<HostConfiguration> =
    { inputs, ... }:
    {
      imports = [
        inputs.self.modules.nixos.<HostHardwareConfiguration>

        # aspects (pick what you want)
        inputs.self.modules.nixos.cli-tools
        inputs.self.modules.nixos.shell

        # keep HM module imported once per host
        inputs.home-manager.nixosModules.home-manager
      ];

      networking.hostName = "<host>";
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      system.stateVersion = "24.05";
    };
}
```

4. Add `modules/hosts/<host>/hardware.nix` as a flake module (if you created one).

Use the existing host as a template (`modules/hosts/nixos-notebook/hardware.nix`). Minimal skeleton:

```nix
{
  flake.modules.nixos.<HostHardwareConfiguration> =
    { ... }:
    {
      # hardware config goes here
    };
}
```

5. Register the host in `modules/hosts/hosts.nix`.

```nix
{ inputs, ... }:
{
  flake.nixosConfigurations.<host> = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [ inputs.self.modules.nixos.<HostConfiguration> ];
  };
}
```

Notes:

- Keep `flake.nixosConfigurations.<host>` consistent with `networking.hostName`; `just rebuild-switch` uses `.#$(hostname)`.
- If you change module names, update the `imports` in `modules/hosts/<host>/configuration.nix` accordingly.

6. Verify without switching:

```sh
nix flake show --all-systems --no-write-lock-file
nix build .#nixosConfigurations.<host>.config.system.build.toplevel -L --no-write-lock-file
```

## Formatting

```sh
nixpkgs-fmt $(git ls-files '*.nix')
stylua modules/dotfiles/nvim
```

## Notes

- Secrets: keep `pass ...` references as-is; do not commit tokens/credentials.
- Safer defaults: prefer `nix build`/`nix eval` before `nixos-rebuild switch`.
