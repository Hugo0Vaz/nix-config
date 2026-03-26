-- General Options
vim.g.mapleader = ' '
vim.g.maplocalleader = ';'
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = {tab = '» ', trail = '·', nbsp = '␣'}
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.colorcolumn = '80'
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.hlsearch = true
vim.opt.wrap = false

-- Fold Options
-- https://www.jackfranklin.co.uk/blog/code-folding-in-vim-neovim/
-- https://gist.github.com/lestoni/8c74da455cce3d36eb68
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 10
vim.opt.foldnestmax = 15

-- Treesitter highlighting (built-in)
vim.treesitter.language.register('bash', 'sh')

