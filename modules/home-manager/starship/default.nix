{ config, flakeRoot, ... }:

{
  programs.starship.enable = true;
  programs.bash.initExtra = ''
  eval "$(starship init bash)"
  '';
  programs.fish.interactiveShellInit = ''
  starship init fish | source
  '';
  programs.zsh.initExtra = ''
  eval "$(starship init zsh)"
  '';

  # Option 1: Copy to store (existing behavior - config is read-only)
  # home.file.".config/starship.toml" = {
  #   source = ./starship.toml;
  # };

  # Option 2: Symlink from repo (config is editable in place)
  home.file.".config/starship.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink "${flakeRoot}/modules/home-manager/starship/starship.toml";
  };
}
