{pkgs, ...}:
{
#     home.packages = with pkgs; [ neovim ];
    programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
    };

   home.file.".config/nvim" = {
     source = ./../../../dotfiles-non-submodule/nvim/.config/nvim;
     recursive = true;
     executable = true;
   };
}
