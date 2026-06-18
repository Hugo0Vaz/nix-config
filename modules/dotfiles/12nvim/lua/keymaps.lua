vim.pack.add({"https://github.com/folke/which-key.nvim"})

require('which-key').setup()

require('which-key').add {
    {"<leader>c", group = "[C]ode"}, {"<leader>c_", hidden = true},
    {"<leader>d", group = "[D]ocument"}, {"<leader>d_", hidden = true},
    {"<leader>r", group = "[R]ename"}, {"<leader>r_", hidden = true},
    {"<leader>s", group = "[S]earch"}, {"<leader>s_", hidden = true},
    {"<leader>w", group = "[W]orkspace"}, {"<leader>w_", hidden = true},
    {"<leader>g", group = "[G]it"}, {"<leader>g_", hidden = true},
    {"<leader>b", group = "[B]uffer"}, {"<leader>b_", hidden = true},
    {"<leader>t", group = "[T]oggle"}, {"<leader>t_", hidden = true},
}

-- Unhighlight search keyman
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n',
        '[d',
        function()
            vim.diagnostic.jump({ count = -1, float = true })
        end,
        { desc = 'Go to previous [D]iagnostic message' })

vim.keymap.set('n',
        ']d',
        function()
            vim.diagnostic.jump({ count = 1, float = true })
        end,
        { desc = 'Go to next [D]iagnostic message' })

vim.keymap.set('n',
        '<leader>e',
        vim.diagnostic.open_float,
        {desc = 'Show diagnostic [E]rror messages'})

vim.keymap.set('n',
        '<leader>q',
        vim.diagnostic.setloclist,
        {desc = 'Open diagnostic [Q]uickfix list'})

-- Terminal keymap helper
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', {desc = 'Exit terminal mode'})

-- Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Buffer remaps
vim.keymap.set('n', '<leader>bn', ':bn<CR>', {desc = '[B]uffer [N]ext'})
vim.keymap.set('n', '<leader>bp', ':bp<CR>', {desc = '[B]uffer [P]revious'})
vim.keymap.set('n', '<leader>bd', ':bd<CR>', {desc = '[B]uffer [D]estroy'})

-- Window remaps
vim.keymap.set('n',
        '<C-h>',
        '<C-w><C-h>',
        {desc = 'Move focus to the left window'})

vim.keymap.set('n',
        '<C-l>',
        '<C-w><C-l>',
        {desc = 'Move focus to the right window'})

vim.keymap.set('n',
        '<C-j>',
        '<C-w><C-j>',
        {desc = 'Move focus to the lower window'})

vim.keymap.set('n',
        '<C-k>',
        '<C-w><C-k>',
        {desc = 'Move focus to the upper window'})

-- Toggle word wrap
vim.keymap.set('n',
    '<Leader>tw',
    ':set wrap!<CR>',
    { desc = '[T]oggle [W]rap Lines' })

-- Move visual selection up (Alt+K)
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")

-- Move visual selection down (Alt+J)
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
