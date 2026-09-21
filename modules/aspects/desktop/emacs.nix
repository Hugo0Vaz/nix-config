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
          extraPackages = epkgs: with epkgs; [ ];
        };

        services.emacs = {
          enable = true;
          startWithUserSession = "graphical";
          client.enable = true;
        };

        # emacs crashes (SIGSEGV in g_file_monitor_source_dispatch) whenever
        # dconf.service comes up fresh while emacs already holds a
        # GSettings/dconf connection — a use-after-free race in dconf's own
        # client code (confirmed backend-agnostic: still happens with
        # GIO_USE_FILE_MONITOR=poll forced). Emacs doesn't rely on any
        # GSettings-backed preference, so keep it off dconf entirely via the
        # in-memory GSettings backend.
        systemd.user.services.emacs.Service.Environment = "GSETTINGS_BACKEND=memory";

        # sops-nix secret for gptel (OpenRouter API key).
        # The decrypted file lands at ~/.config/sops-nix/secrets/openrouter_api_key.
        # Emacs reads it at runtime via `ugo/openrouter-api-key`.
        sops.secrets.openrouter_api_key = { };

        home.file.".config/emacs/init.el".source =
          config.lib.file.mkOutOfStoreSymlink "${config.programs.emacs.emacsDotfileRoot}/init.el";

        home.file.".config/emacs/early-init.el".source =
          config.lib.file.mkOutOfStoreSymlink "${config.programs.emacs.emacsDotfileRoot}/early-init.el";
      };
    };
}
