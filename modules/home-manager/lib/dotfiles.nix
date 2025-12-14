{ config, self, ... }:

{
  # Helper function to create out-of-store symlinks for dotfiles
  # This makes it easier to manage dotfiles that you want to edit in place

  lib.dotfiles = {
    # Create a symlink to a file/directory in the flake
    # Usage: dotfiles.link "modules/home-manager/nvim/init.lua" ".config/nvim/init.lua"
    link = relativePath: target: {
      "${target}" = {
        source = config.lib.file.mkOutOfStoreSymlink "${self}/${relativePath}";
      };
    };

    # Create symlinks for multiple files at once
    # Usage: dotfiles.linkMany {
    #   "modules/home-manager/nvim/init.lua" = ".config/nvim/init.lua";
    #   "modules/home-manager/tmux/.tmux.conf" = ".tmux.conf";
    # }
    linkMany = pathsToTargets:
      builtins.foldl' (acc: entry:
        acc // (config.lib.dotfiles.link entry.relativePath entry.target)
      ) {} (
        builtins.map (relativePath: {
          inherit relativePath;
          target = pathsToTargets.${relativePath};
        }) (builtins.attrNames pathsToTargets)
      );
  };
}
