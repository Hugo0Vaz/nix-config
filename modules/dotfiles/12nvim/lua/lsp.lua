vim.pack.add({"https://github.com/neovim/nvim-lspconfig"})

-- Lua LS config
vim.lsp.enable('lua_ls')
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
      hint = {
        enable = true,
        setType = true,
      },
    },
  },
})

vim.lsp.enable('nixd')
vim.lsp.enable('phpactor')
vim.lsp.enable('gopls')
vim.lsp.enable('rust_analyzer')
vim.lsp.enable('ts_ls')
vim.lsp.enable('html')
vim.lsp.enable('tailwindcss')
vim.lsp.enable('pyright')

