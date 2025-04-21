{ pkgs ? import <nixpkgs> {} }:

pkgs.buildGoModule {
  pname = "propener";
  version = "v0.1.0"; # or specific version
  src = pkgs.fetchFromGitHub {
    owner = "Hugo0Vaz";
    repo = "pr-opener";
    rev = "v0.1.0"; # e.g., "v1.2.0" or "a1b2c3d"
    hash = "sha256-w2sJv0rjADDgBTKUU0KswrPxhAZZ1dMlJL7lQAxXTKg=";
  };

  vendorHash = "sha256-hLT1ogwn8Y61uMXD6H2O3OsNitAE39kmCE+tOxlQDTg=";
}


