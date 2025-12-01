{ inputs, self, ... }: {
  perSystem = { pkgs, system, ... }: {
    checks = {
      # Check that NixOS configuration builds
      nixos-workstation = self.nixosConfigurations.nixos-workstation.config.system.build.toplevel;

      # Check that Home Manager configurations build (only for x86_64-linux)
    } // pkgs.lib.optionalAttrs (system == "x86_64-linux") {
      home-wsl = self.homeConfigurations.wsl.activationPackage;
      home-ubuntu = self.homeConfigurations.ubuntu.activationPackage;
    };
  };
}
