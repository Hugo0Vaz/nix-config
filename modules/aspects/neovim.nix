{
  flake.modules.nixos.neovim =
    { inputs, lib, config, ... }:
    {
      options.programs.neovim.nvimCfgRoot= lib.mkOption {
        type = lib.types.str;
        description = "Realpath of the neovim configuration";
        default = "/home/hugomvs/Projetos/nix-config/modules/dotfiles/nvim/";
        example = "/home/hugomvs/Projetos/nix-config/modules/dotfiles/nvim/";
      };

      config = {
        home-manager.sharedModules = [
          inputs.self.modules.homeManager.neovim
          {
            programs.neovim.nvimCfgRoot = config.programs.neovim.nvimCfgRoot;
          }
        ];
      };
    };

  flake.modules.homeManager.neovim =
    { config, pkgs, lib, ... }:
    {
      options.programs.neovim.nvimCfgRoot = lib.mkOption {
        type = lib.types.str;
        description = "Realpath of the neovim configuration";
        default = "/home/hugomvs/Projetos/nix-config/modules/dotfiles/nvim/";
        example = "/home/hugomvs/Projetos/nix-config/modules/dotfiles/nvim/";
      };

      config = {
        home.packages = with pkgs; [
          neovim
          ripgrep
          fd
          tree-sitter
          nodejs_22
          gcc
          nixd
          lua-language-server
        ];

        home.file.".config/nvim" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.programs.neovim.nvimCfgRoot}";
        };
      };
    };
}
