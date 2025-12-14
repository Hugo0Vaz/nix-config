# Dotfiles Management with mkOutOfStoreSymlink

This repository uses `mkOutOfStoreSymlink` to manage dotfiles, allowing you to edit configuration files in place without rebuilding your system.

## Overview

There are two approaches to managing dotfiles in Nix:

1. **Copy to Store** (default Nix behavior): Config files are copied to the read-only Nix store
   - Pros: Reproducible, immutable
   - Cons: Must rebuild to see changes

2. **Symlink from Repository** (using `mkOutOfStoreSymlink`): Config files are symlinked from your repository
   - Pros: Edit in place, see changes immediately
   - Cons: Requires repository to be present at the same path

## How it Works

The flake passes its own path (`self`) through `specialArgs` to all configurations:

```nix
# modules/hosts/default.nix
nixosConfigurations = {
  nixos-workstation = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs outputs self; };
    modules = [
      # ...
      {
        home-manager.extraSpecialArgs = { inherit self; };
        # ...
      }
    ];
  };
};
```

Then modules can use `self` to create absolute paths:

```nix
{ config, self, ... }: {
  home.file.".config/foo/config" = {
    source = config.lib.file.mkOutOfStoreSymlink "${self}/modules/home-manager/foo/config";
  };
}
```

## Usage Examples

### Basic Example

```nix
{ config, self, pkgs, ... }: {
  home.packages = with pkgs; [ myapp ];

  home.file.".config/myapp/config" = {
    source = config.lib.file.mkOutOfStoreSymlink "${self}/modules/home-manager/myapp/config";
  };
}
```

### Multiple Files

```nix
{ config, self, ... }: {
  home.file.".config/waybar/config" = {
    source = config.lib.file.mkOutOfStoreSymlink "${self}/modules/home-manager/waybar/config";
  };

  home.file.".config/waybar/style.css" = {
    source = config.lib.file.mkOutOfStoreSymlink "${self}/modules/home-manager/waybar/style.css";
  };
}
```

### Choosing Between Copy and Symlink

```nix
{ config, self, ... }: {
  # Copy to store - for configs you rarely change
  home.file.".config/readonly-app/config" = {
    source = ./config;
  };

  # Symlink from repo - for configs you frequently edit
  home.file.".config/editable-app/config" = {
    source = config.lib.file.mkOutOfStoreSymlink "${self}/modules/home-manager/editable-app/config";
  };
}
```

## Path Construction

The path format is: `"${self}/path/relative/to/flake/root"`

Examples:
- Waybar config: `"${self}/modules/home-manager/waybar/config"`
- Tmux config: `"${self}/modules/home-manager/tmux/.tmux.conf"`
- Starship config: `"${self}/modules/home-manager/starship/starship.toml"`

## Important Notes

1. **Absolute Paths Required**: `mkOutOfStoreSymlink` requires absolute paths. Using `self` provides this.

2. **Repository Location**: The symlinks will break if you move your repository. When moving:
   ```bash
   # After moving the repo, rebuild to update symlinks
   rebuildSystem  # or rebuildHome
   ```

3. **Git Status**: Changes to symlinked files won't trigger rebuilds, but you should still commit them to git.

4. **WSL and Non-NixOS**: The pattern works the same way on all configurations since `extraSpecialArgs` is set for all home configurations.

## Current Modules Using This Pattern

- `waybar`: Waybar status bar configuration
- `starship`: Shell prompt configuration
- `tmux`: Terminal multiplexer configuration
- `ghostty`: Terminal emulator configuration

## Adding to New Modules

1. Add `self` to the module arguments:
   ```nix
   { config, self, pkgs, ... }:
   ```

2. Use `mkOutOfStoreSymlink` with absolute path:
   ```nix
   home.file.".config/myapp/config" = {
     source = config.lib.file.mkOutOfStoreSymlink "${self}/modules/home-manager/myapp/config";
   };
   ```

3. Test the configuration:
   ```bash
   nix flake check
   ```
