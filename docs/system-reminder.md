# nixos-notebook host password (sops-nix)

This repo uses `sops-nix` and the convention `secrets/${hostName}.yaml`.

## 1) Store the hashed password in sops

Edit the host secrets file:

```bash
sops secrets/nixos-notebook.yaml
```

Add a key (example name):

```yaml
hugomvs_hashed_password: "$y$j9T$glg2X4gkqAF0lKn3zCGXW1$tQDaQ7QJhAFiA4T9.Y3O3DFn6oCta2TJ1Nw2unNl611"
```

## 2) Tell NixOS to use it during user creation

In the module that defines the user (e.g. `modules/aspects/hugo.nix`):

```nix
{ config, ... }:
{
  # Ensure the secret is decrypted before NixOS creates users.
  sops.secrets.hugomvs_hashed_password.neededForUsers = true;

  users.users.hugomvs = {
    # Do not keep initialPassword when using hashedPasswordFile.
    hashedPasswordFile = config.sops.secrets.hugomvs_hashed_password.path;
  };
}
```

Notes:
- `neededForUsers = true` makes the secret available early under `/run/secrets-for-users`.
- Remove any `users.users.<name>.initialPassword` once you switch to `hashedPasswordFile`.
