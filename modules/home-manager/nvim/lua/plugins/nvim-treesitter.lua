return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",

  opts = {
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
  },

  config = function(_, opts)
    -- Custom parser MUST be defined before setup()
    local parsers = require("nvim-treesitter.parsers")
    parsers.configs = parsers.configs or {}

    parsers.configs.blade = {
      install_info = {
        url = "https://github.com/EmranMR/tree-sitter-blade",
        files = { "src/parser.c" },
        branch = "main",
      },
      filetype = "blade",
    }

    require("nvim-treesitter.configs").setup(opts)
  end,
}

