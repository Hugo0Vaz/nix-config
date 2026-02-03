{ pkgs, inputs, ... }:
{
  imports = [
    inputs.try.homeModules.default
  ];

  programs.try = {
    enable = true;
    path = "~/Projetos/tries";  # optional, defaults to ~/src/tries
  };

}
