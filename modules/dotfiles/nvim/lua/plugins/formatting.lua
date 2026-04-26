return {
  'stevearc/conform.nvim',
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return
      end
      return {
        timeout_ms = 500,
        lsp_format = 'fallback',
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'autopep8' },
      php = { 'php_cs_fixer' },
      blade = { 'blade-formatter' },
      nix = { 'nixpkgs_fmt' },
      javascript = { 'prettierd' },
      html = { 'html_beautify' },
      yaml = { 'yamlfix' },
    },
  },
  keys = {
    {
      '<leader>bf',
      function()
        print 'Formatting buffer...'
        require('conform').format()
      end,
      noremap = true,
      silent = false,
      desc = '[B]uffer [F]ormat',
    },
  },
}
