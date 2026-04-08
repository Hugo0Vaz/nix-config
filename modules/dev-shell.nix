{ inputs, ... }:
{
  perSystem = { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = "nix-config";

        packages = with pkgs; [
          nixpkgs-fmt
          nix-tree
          nix-diff
          lua-language-server
          stylua
          git
          nil
          just
          fzf
          inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      };
    };
}
