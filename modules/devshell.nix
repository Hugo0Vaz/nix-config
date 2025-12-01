{ inputs, self, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      # Development shell
      devShells.default = pkgs.mkShell {
        name = "nix-config-dev";

        packages = with pkgs; [
          # Nix tooling
          nixpkgs-fmt
          nix-tree
          nix-diff

          # Development tools
          git
          inputs.home-manager.packages.${pkgs.system}.default
        ];

        shellHook = ''
          echo "🚀 NixOS/Home-Manager development environment"
          echo ""
          echo "Available commands:"
          echo "  nixpkgs-fmt    - Format Nix files"
          echo "  nix-tree       - Explore dependency trees"
          echo "  nix-diff       - Compare derivations"
          echo "  home-manager   - Home Manager CLI"
          echo ""
          echo "Custom scripts:"
          echo "  updateSystem   - Update flake inputs"
          echo "  rebuildSystem  - Rebuild NixOS configuration"
          echo "  rebuildHome    - Rebuild Home Manager configuration"
        '';
      };

      # Formatter
      formatter = pkgs.nixpkgs-fmt;

      # Checks
      checks =
        {
          # Check that NixOS configuration builds
          nixos-workstation = self.nixosConfigurations.nixos-workstation.config.system.build.toplevel;

          # Check that Home Manager configurations build (only for x86_64-linux)
        }
        // pkgs.lib.optionalAttrs (system == "x86_64-linux") {
          home-wsl = self.homeConfigurations.wsl.activationPackage;
          home-ubuntu = self.homeConfigurations.ubuntu.activationPackage;
        };
    };
}
