{ inputs, self, ... }:
{
  systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

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
        nil
        just
        fzf
        inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };
}
