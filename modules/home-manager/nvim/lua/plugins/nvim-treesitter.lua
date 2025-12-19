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
    -- Setup treesitter first
    require("nvim-treesitter").setup(opts)
    
    -- Then register custom blade parser
    vim.treesitter.language.register("blade", "blade")
  end,
}
