{ ... }: {

  programs.fish.enable = true;
  programs.fish.promptInit = ''
    starship init fish | source
  '';

  programs.fish.interactiveShellInit = ''

  '';

}
