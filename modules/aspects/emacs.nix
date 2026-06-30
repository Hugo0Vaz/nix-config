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
        services.emacs.enable = true;
        services.emacs.package = pkgs.emacs-pgtk;
        services.emacs.startWithGraphical = true;

        environment.systemPackages = [
          pkgs.emacs-pgtk
        ];

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
        home.packages = with pkgs; [
          emacs-pgtk
        ];

        home.file.".config/emacs/init.el".source =
          config.lib.file.mkOutOfStoreSymlink "${config.programs.emacs.emacsDotfileRoot}/init.el";
      };
    };
}
