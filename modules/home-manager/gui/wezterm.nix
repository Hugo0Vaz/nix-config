{...}:
{
    programs.wezterm.enable =  true;

    home.file.".config/wezterm/wezterm.lua" = {
     source = ./../../../dotfiles/wezterm/.config/wezterm/wezterm.lua;
     executable = true;
    };
}
