{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
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
  };
}
