{...}:
{
  programs.wofi.enable = true;
  programs.wofi.settings = {
    location = "center";
    allow_markup = true;
    width = 250;
  };
  programs.wofi.style = (builtins.readFile ./../../../dotfiles/wofi/.config/wofi/style.css);
}
