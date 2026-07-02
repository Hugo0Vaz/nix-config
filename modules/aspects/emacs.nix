{
  flake.modules.nixos.emacs =
    { inputs, lib, config, pkgs, ... }:
    {
      options.programs.emacs.emacsDotfileRoot = lib.mkOption {
        type = lib.types.str;
        description = "Realpath of the Emacs dotfiles directory";
        default = "/home/hugomvs/Projetos/nix-config/modules/dotfiles/emacs/";
        example = "/home/hugomvs/Projetos/nix-config/modules/dotfiles/emacs/";
      };

      config = {
        home-manager.sharedModules = [
          inputs.self.modules.homeManager.emacs
          {
            programs.emacs.emacsDotfileRoot = config.programs.emacs.emacsDotfileRoot;
          }
        ];
      };
    };

  flake.modules.homeManager.emacs =
    { config, pkgs, lib, ... }:
    {
      options.programs.emacs.emacsDotfileRoot = lib.mkOption {
        type = lib.types.str;
        description = "Realpath of the Emacs dotfiles directory";
        default = "/home/hugomvs/Projetos/nix-config/modules/dotfiles/emacs/";
        example = "/home/hugomvs/Projetos/nix-config/modules/dotfiles/emacs/";
      };

      config = {
        programs.emacs = {
          enable = true;
          package = pkgs.emacs-pgtk;
          extraPackages = epkgs: with epkgs; [
            use-package
            markdown-mode
            gruvbox-theme
            magit
            company
          ];
        };

        services.emacs = {
          enable = true;
          startWithUserSession = "graphical";
          client.enable = true;
        };

        home.file.".config/emacs/init.el".source =
          config.lib.file.mkOutOfStoreSymlink "${config.programs.emacs.emacsDotfileRoot}/init.el";

        home.file.".config/emacs/early-init.el".source =
          config.lib.file.mkOutOfStoreSymlink "${config.programs.emacs.emacsDotfileRoot}/early-init.el";
      };
    };
}
