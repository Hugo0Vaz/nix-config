-- [[ Bootstrap of `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    vim.fn.system {
        'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo,
        lazypath
    }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('options')
require('commands')
require('autocommands')
require('keymaps')

require('lazy').setup('plugins', {
  rocks = {
    luarocks = false, -- Disable LuaRocks integration
    hererocks = false, -- Disable Hererocks integration
    enable = false,
  },
})
