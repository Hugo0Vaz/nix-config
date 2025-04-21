{ pkgs ? import <nixpkgs> {} }:

pkgs.buildGoModule {
  pname = "propener";
  version = "v0.1.0"; # or specific version
  src = pkgs.fetchFromGitHub {
    owner = "Hugo0Vaz";
    repo = "pr-opener";
    rev = "v0.1.0"; # e.g., "v1.2.0" or "a1b2c3d"
    hash = "sha256-tFFjHqXJZA+tfvVr+K1l4hwuyhHwNS32pY4F59JD8Go=";
  };

  vendorHash = "sha256-+krL0+aSHNX4xbBbzNR76zzaR5Yg1cPM5h+9In8s0XQ=";
}
