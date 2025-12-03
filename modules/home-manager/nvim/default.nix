{ lib, ... }: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  home.file.".config/nvim" = {
    source = lib.cleanSourceWith {
      src = ./.;
      filter = path: type:
        let baseName = baseNameOf path;
        in baseName != "default.nix" && baseName != "README.md";
    };
    recursive = true;
  };
}

