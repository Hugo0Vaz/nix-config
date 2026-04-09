{ inputs, ... }:
{
  flake.homeConfigurations = {
  "hugom@kot225" =
      let
        system = "x86_64-linux";
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [ inputs.self.modules.homeManager.kot225wslHomeConfiguration ];
      };
  };
}
