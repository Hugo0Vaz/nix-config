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
    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    parser_config.blade = {
      install_info = {
        url = "https://github.com/EmranMR/tree-sitter-blade",
        files = { "src/parser.c" },
        branch = "main",
      },
      filetype = "blade",
    }
    require("nvim-treesitter").setup(opts)
  end,
}
