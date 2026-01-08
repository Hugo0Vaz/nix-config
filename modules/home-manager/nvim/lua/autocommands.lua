-- [[ Basic Autocommands ]]

-- Highlight when yanking text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('highlight-yank', {clear = true}),
    callback = function() vim.highlight.on_yank() end
})

-- Custom filetype detection
local filetype_group = vim.api.nvim_create_augroup('custom-filetypes', {clear = true})

-- Scratch buffer as markdown
vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
    group = filetype_group,
    pattern = '_SCRATCH_',
    callback = function()
        vim.bo.filetype = 'markdown'
    end
})

-- Go templ files
vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
    group = filetype_group,
    pattern = '*.templ',
    callback = function()
        vim.bo.filetype = 'templ'
    end
})

-- Laravel Blade templates
vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
    group = filetype_group,
    pattern = '*.blade.php',
    callback = function()
        vim.bo.filetype = 'blade'
    end
})

-- Enable treesitter highlighting for all filetypes
vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('treesitter-highlight', {clear = true}),
    pattern = '*',
    callback = function(args)
        pcall(vim.treesitter.start, args.buf)
    end
})

