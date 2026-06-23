vim.pack.add({'https://github.com/stevearc/conform.nvim.git'})

require("conform").setup({
    formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'autopep8' },
        php = { 'php_cs_fixer' },
        -- blade = { 'blade-formatter' },
        nix = { 'nixpkgs_fmt' },
        -- javascript = { 'prettierd' },
        -- html = { 'html_beautify' },
        yaml = { 'yamlfix' },
    },
    format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 500,
        lsp_format = "fallback",
    },
})

