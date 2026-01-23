{ pkgs, config, ... }:
{
  stylix = {
    enable = true;
    
    # Use image-based theming with Gruvbox-like wallpaper, or use base16Scheme
    # Option 1: Use a wallpaper (Stylix will extract colors from it)
    # image = ./path/to/wallpaper.jpg;
    
    # Option 2: Use base16 scheme directly from the schemes input
    base16Scheme = {
      base00 = "282828"; # ---- (Gruvbox Dark Medium - matches tmux/ghostty)
      base01 = "3c3836"; # ---
      base02 = "504945"; # --
      base03 = "665c54"; # -
      base04 = "bdae93"; # +
      base05 = "d5c4a1"; # ++
      base06 = "ebdbb2"; # +++
      base07 = "fbf1c7"; # ++++
      base08 = "fb4934"; # red
      base09 = "fe8019"; # orange
      base0A = "fabd2f"; # yellow
      base0B = "b8bb26"; # green
      base0C = "8ec07c"; # aqua/cyan
      base0D = "83a598"; # blue
      base0E = "d3869b"; # purple
      base0F = "d65d0e"; # brown
    };
    
    # Set cursor theme
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
    
    # Set fonts
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sizes = {
        applications = 12;
        terminal = 12;
        desktop = 10;
        popups = 10;
      };
    };
    
    # Opacity settings
    opacity = {
      applications = 1.0;
      terminal = 0.95;
      desktop = 1.0;
      popups = 1.0;
    };
  };
}
