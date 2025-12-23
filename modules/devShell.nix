{ inputs, self, ... }:
{
  perSystem = { pkgs, system, ... }:
  {
    devShells.default = pkgs.mkShell {
      name = "nix-config-dev";

      packages = with pkgs; [
        nixpkgs-fmt
        nix-tree
        nix-diff
        lua-language-server
        stylua
        git
        inputs.home-manager.packages.${pkgs.system}.default
      ];
    };
  };
}
