# nix-config

## Install

### NixOS

1. Clone the repo to `~/.config`.

```shell
cd ~/.config
git clone git@github.com:Hugo0Vaz/nix-config.git
```

2. Edit the following line to point to the correct path of the repo
```flake.nix
_module.args = {
  flakeRoot =
    if builtins.pathExists "/home/hugomvs/Projetos/nix-config"
    then "/home/hugomvs/Projetos/nix-config"
    else "/etc/nixos";
};
```

3. Run the configurations rebuild.

```shell
sudo nixos-rebuild switch --flake .#<host_config_name>
```

### Home Manager

1. Clone the repo to `~/.config`

```shell
cd ~/.config
git clone git@github.com:Hugo0Vaz/nix-config.git
```

2. 
