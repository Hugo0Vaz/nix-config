return {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
        require('which-key').setup()

        require('which-key').register {
            {"<leader>c", group = "[C]ode"}, {"<leader>c_", hidden = true},
            {"<leader>d", group = "[D]ocument"}, {"<leader>d_", hidden = true},
            {"<leader>r", group = "[R]ename"}, {"<leader>r_", hidden = true},
            {"<leader>s", group = "[S]earch"}, {"<leader>s_", hidden = true},
            {"<leader>w", group = "[W]orkspace"}, {"<leader>w_", hidden = true}
        }
    end
}
