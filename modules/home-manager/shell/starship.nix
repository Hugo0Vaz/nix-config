{...}:

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

  home.file.".config/starship.toml" = {
    source = ./../../../dotfiles/starship/starship.toml;
  };
}
