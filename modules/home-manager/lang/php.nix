{ pkgs, ... }: { home.packages = with pkgs; [ php php83Packages.composer ]; }
