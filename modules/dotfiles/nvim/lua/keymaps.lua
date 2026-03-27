-- Unhighlight search keyman
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,
               {desc = 'Go to previous [D]iagnostic message'})
vim.keymap.set('n', ']d', vim.diagnostic.goto_next,
               {desc = 'Go to next [D]iagnostic message'})
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float,
               {desc = 'Show diagnostic [E]rror messages'})
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist,
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
vim.keymap.set('n', '<C-h>', '<C-w><C-h>',
               {desc = 'Move focus to the left window'})
vim.keymap.set('n', '<C-l>', '<C-w><C-l>',
               {desc = 'Move focus to the right window'})
vim.keymap.set('n', '<C-j>', '<C-w><C-j>',
               {desc = 'Move focus to the lower window'})
vim.keymap.set('n', '<C-k>', '<C-w><C-k>',
               {desc = 'Move focus to the upper window'})

-- Toggle word wrap
vim.api.nvim_set_keymap('n', '<Leader>tw', ':set wrap!<CR>', { desc = '[T]oggle [W]rap Lines' })
