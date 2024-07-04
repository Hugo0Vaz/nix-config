{ pkgs, options, ... }:

let
  helloWorld = pkgs.writeShellScriptBin "helloWorld" ''
    echo Hello World
  '';

in { home = { environment.systemPackages = [ helloWorld ]; }; }
