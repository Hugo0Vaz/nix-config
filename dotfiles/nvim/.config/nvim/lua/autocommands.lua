-- [[ Basic Autocommands ]]
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank',
                                        {clear = true}),
    callback = function() vim.highlight.on_yank() end
})

vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*',
    callback = function(args) require('conform').format {bufnr = args.buf} end
})

vim.api.nvim_create_autocmd({'BufEnter', 'BufRead', 'BufNewFile'}, {
    pattern = '_SCRATCH_',
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_set_option_value('filetype', 'markdown', {buf = buf})
    end
})

vim.api.nvim_create_autocmd({'BufEnter', 'BufRead', 'BufNewFile'}, {
    pattern = '*.templ',
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_set_option_value('filetype', 'templ', {buf = buf})
    end
})

vim.api.nvim_create_autocmd({'BufEnter', 'BufRead', 'BufNewFile'}, {
    pattern = '*.blade.php',
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_set_option_value('filetype', 'html.blade', {buf = buf})
    end
})

vim.api.nvim_create_autocmd({'BufEnter', 'BufRead', 'BufNewFile'}, {
    pattern = '*.nix',
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_set_option_value('filetype', 'nix', {buf = buf})
    end
})

