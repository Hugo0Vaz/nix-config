return {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
        'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons',
        'MunifTanjim/nui.nvim'
    },
    config = function()
        vim.keymap.set('n', '<leader>n', '<Cmd>Neotree toggle<CR>', {desc = '[N]eotree Explorer'})
        require('neo-tree').setup({filesystem = {
          filtered_items = {
            visible = false, -- when true, they will just be displayed differently
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_by_name = {
              -- "node_modules"
            },
            never_show = { -- remains hidden even if visible is toggled to true
              -- ".DS_Store",
              -- "thumbs.db"
            },
          },
          follow_current_file = {enabled = true}, -- This will find and focus the file in the active buffer every time
          hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
          use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
        }})
    end
}
