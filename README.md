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

## Installation

### NixOS

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
# available NixOS configurations: nixos-notebook, nixos-server
sudo nixos-rebuild switch --flake .#nixos-notebook

# or via just (targets current hostname)
just rebuild-test
just rebuild-switch
```

### Non-NixOS (Home-Manager Standalone)

For non-NixOS systems (e.g., WSL, macOS, or any Linux distro), use Home-Manager as a standalone configuration.

1. Clone the repo.

```sh
git clone git@github.com:Hugo0Vaz/nix-config.git
cd nix-config
```

2. Install Home-Manager (if not already installed).

```sh
nix run home-manager/master -- init --switch
```

3. Build and activate your configuration.

```sh
# available Home-Manager configurations: hugom@kot225 (WSL example)
nix run home-manager/master -- switch --flake .#hugom@kot225

# or use the direct flake reference
home-manager switch --flake .#hugom@kot225
```

4. For custom non-NixOS hosts, create a new Home-Manager config under `modules/hosts/<your-host>/` with a `home.nix` module and expose it via `default.nix` (see `modules/hosts/kot225wsl/` as a template).

## Home-Manager

Home-Manager is used via the NixOS module (`inputs.home-manager.nixosModules.home-manager`), not as a standalone `homeConfigurations.*` output.

Update user config through aspects in `modules/aspects/*.nix` (wired via `home-manager.sharedModules`) and rebuild NixOS.

## Repo Layout

- `flake.nix`: flake entrypoint (uses flake-parts and import-tree)
- `modules/flake-parts.nix`: flake-parts configuration and system definitions
- `modules/dev-shell.nix`: development environment shell
- `modules/hosts/`: Host configurations (both NixOS and Home-Manager standalone)
  - `modules/hosts/nixos-notebook/`: NixOS laptop configuration
    - `configuration.nix`: host imports and NixOS options
    - `hardware.nix`: hardware-specific settings
    - `default.nix`: flake module exports
  - `modules/hosts/nixos-server/`: NixOS server configuration
    - `configuration.nix`: host imports and NixOS options
    - `hardware-configuration.nix`: hardware-specific settings
    - `default.nix`: flake module exports
  - `modules/hosts/kot225wsl/`: Home-Manager standalone (WSL example)
    - `home.nix`: Home-Manager configuration
    - `default.nix`: flake exports (`homeConfigurations`)
- `modules/aspects/`: Composable NixOS/Home-Manager modules (e.g., `cli-tools.nix`, `shell.nix`)
- `modules/homeManager/`: Home-Manager specific modules
- `modules/dotfiles/`: Managed dotfiles (notably Neovim configuration)
- `modules/_scripts/`: Packaged helper scripts (`pkgs.writeShellScriptBin`)

## Adding A New Host

### Adding a NixOS Host

1. Create a host directory:

```sh
mkdir -p modules/hosts/<hostname>
```

2. Create `modules/hosts/<hostname>/hardware.nix`.

If you are on the target machine, you can generate this and then copy the relevant parts:

```sh
sudo nixos-generate-config --show-hardware-config
```

Use the existing host as a template (`modules/hosts/nixos-notebook/hardware.nix`). Minimal skeleton:

```nix
{
  flake.modules.nixos.<HostnameHardware> =
    { ... }:
    {
      # hardware config goes here
    };
}
```

3. Create `modules/hosts/<hostname>/configuration.nix`.

Use the existing host as a template (`modules/hosts/nixos-notebook/configuration.nix`). Minimal skeleton:

```nix
{
  flake.modules.nixos.<HostnameConfiguration> =
    { inputs, ... }:
    {
      imports = [
        inputs.self.modules.nixos.<HostnameHardware>

        # aspects (pick what you want)
        inputs.self.modules.nixos.cli-tools
        inputs.self.modules.nixos.shell

        # keep HM module imported once per host
        inputs.home-manager.nixosModules.home-manager
      ];

      networking.hostName = "<hostname>";
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      system.stateVersion = "24.05";
    };
}
```

4. Create `modules/hosts/<hostname>/default.nix`.

This exposes your NixOS configuration as a flake output:

```nix
{ inputs, ... }:
{
  flake.nixosConfigurations.<hostname> = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [ inputs.self.modules.nixos.<HostnameConfiguration> ];
  };
}
```

5. Verify without switching:

```sh
nix flake show --all-systems --no-write-lock-file
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel -L --no-write-lock-file
```

Notes:

- Keep `flake.nixosConfigurations.<hostname>` consistent with `networking.hostName`; `just rebuild-switch` uses `.#$(hostname)`.
- If you change module names, update the `imports` in `modules/hosts/<hostname>/configuration.nix` accordingly.

### Adding a Non-NixOS (Home-Manager Standalone) Host

1. Create a host directory:

```sh
mkdir -p modules/hosts/<hostname>
```

2. Create `modules/hosts/<hostname>/home.nix`.

Use the existing WSL configuration as a template (`modules/hosts/kot225wsl/home.nix`). Minimal skeleton:

```nix
{
  flake.modules.homeManager.<HostnameHMConfiguration> =
    { inputs, lib, ... }:
    {
      imports = [
        inputs.self.modules.homeManager.cli-tools
        inputs.self.modules.homeManager.shell
      ];

      targets.genericLinux.enable = true; # or macOS, depending on your system

      home.username = "<username>";
      home.homeDirectory = "/home/<username>";
      home.stateVersion = "24.05";
      programs.home-manager.enable = true;
    };
}
```

3. Create `modules/hosts/<hostname>/default.nix`.

This exposes your Home-Manager configuration as a flake output:

```nix
{ inputs, ... }:
{
  flake.homeConfigurations = {
    "<username>@<hostname>" =
      let
        system = "x86_64-linux"; # or aarch64-linux, x86_64-darwin, etc.
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [ inputs.self.modules.homeManager.<HostnameHMConfiguration> ];
      };
  };
}
```

4. Activate your configuration:

```sh
home-manager switch --flake .#<username>@<hostname>
```

## Formatting

```sh
nixpkgs-fmt $(git ls-files '*.nix')
stylua modules/dotfiles/nvim
```

## Notes

- Secrets: keep `pass ...` references as-is; do not commit tokens/credentials.
- Safer defaults: prefer `nix build`/`nix eval` before `nixos-rebuild switch`.
