{
  flake.modules.homeManager.tmux-sessionizer =
    { pkgs, lib, config, ... }:
    {
      options.my.tmux.projDir = lib.mkOption {
        type = lib.types.str;
        default = "/home/hugomvs/Projetos";
        description = "Base directory where projects are stored, used by tmux-sessionizer.";
      };

      config.home.packages = [
        (pkgs.writeShellScriptBin "tmux-sessionizer" ''

          PROJ_DIR="${config.my.tmux.projDir}"

          if [[ $# -eq 1 ]]; then
              selected=$1
          else
              selected_name=$(find $PROJ_DIR -mindepth 1 -maxdepth 1 -type d | xargs basename -a | fzf)
              selected="$PROJ_DIR/$selected_name"
          fi

          if [[ -z $selected ]]; then
              exit 0
          fi

          tmux_running=$(pgrep tmux)

          echo $selected

          if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
              tmux new-session -s $selected_name -c $selected
              exit 0
          fi

          if ! tmux has-session -t=$selected_name 2> /dev/null; then
              tmux new-session -ds $selected_name -c $selected
          fi

          tmux switch-client -t $selected_name
        '')
      ];
    };
}
