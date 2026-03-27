return {
    'https://git.sr.ht/~swaits/scratch.nvim',
    lazy = true,
    keys = {
        {'<leader>bs', '<cmd>Scratch<cr>', desc = '[B]uffer [S]cratch', mode = 'n'},
        {
            '<leader>bS',
            '<cmd>ScratchSplit<cr>',
            desc = '[B]uffer [S]plit Scratch',
            mode = 'n'
        }
    },
    cmd = {'Scratch', 'ScratchSplit'},
    opts = {}
}
