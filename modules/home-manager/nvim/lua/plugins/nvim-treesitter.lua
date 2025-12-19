return { -- Highlight, edit, and navigate code
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    -- [[ Configure custom Treesitter parsers ]]
    local parsers = require("nvim-treesitter.parsers")

    -- Ensure configs table exists (required on newer versions)
    parsers.configs = parsers.configs or {}

    parsers.configs.blade = {
      install_info = {
        url = "https://github.com/EmranMR/tree-sitter-blade",
        files = { "src/parser.c" },
        branch = "main",
      },
      filetype = "blade",
    }

    ---@diagnostic disable-next-line: missing-fields
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "bash",
        "c",
        "html",
        "lua",
        "markdown",
        "vim",
        "vimdoc",
        "php",
        "blade",
        "json",
        "yaml",
        "dockerfile",
        "templ",
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}

