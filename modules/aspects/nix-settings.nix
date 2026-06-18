{
  flake.modules.nixos.nix-settings =
    { lib, ... }: {
      nixpkgs.config.allowUnfree = lib.mkDefault true;
      nixpkgs.config.permittedInsecurePackages = [
        "electron-39.8.10"
      ];
      nix.settings.experimental-features = lib.mkDefault [ "nix-command" "flakes" ];
      home-manager.sharedModules = [
        ({ ... }: {
          nixpkgs.config.allowUnfree = lib.mkDefault true;
          nixpkgs.config.permittedInsecurePackages = [
            "electron-39.8.10"
          ];
        })
      ];
    };

  flake.modules.homeManager.nix-settings =
    { lib, ... }: {
      nixpkgs.config.allowUnfree = lib.mkDefault true;
      nixpkgs.config.permittedInsecurePackages = [
        "electron-39.8.10"
      ];
    };
}
