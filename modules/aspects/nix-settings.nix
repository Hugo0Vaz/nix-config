{
  flake.modules.nixos.nix-settings =
    { lib, ... }: {
      nixpkgs.config.allowUnfree = lib.mkDefault true;
      nixpkgs.config.permittedInsecurePackages = [
        "nodejs-20.20.2"
        "nodejs-slim-20.20.2"
        "electron-39.8.10"
      ];
      nix.settings.experimental-features = lib.mkDefault [ "nix-command" "flakes" ];
    };
}
