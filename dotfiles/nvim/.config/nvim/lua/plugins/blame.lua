return {
    'FabijanZulj/blame.nvim',
    config = function()
        require('blame').setup()
        vim.keymap.set('', '<leader>gb', ':BlameToggle window<CR>',
                       {desc = 'Toggles [G]it [B]lame Window'})
    end
}
