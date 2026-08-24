{
  flake.modules.nixos.docgen =
    { inputs, ... }:
    {
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.docgen
      ];
    };

  flake.modules.homeManager.docgen =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        pandoc
        typst
      ];
    };
}