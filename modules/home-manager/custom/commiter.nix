{ pkgs }:

pkgs.buildGoModule {
  pname = "commiter";
  version = "v0.1.0"; # or specific version
  src = pkgs.fetchFromGitHub {
    owner = "Hugo0Vaz";
    repo = "commiter";
    rev = "v0.1.0"; # e.g., "v1.2.0" or "a1b2c3d"
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  vendorHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
}
