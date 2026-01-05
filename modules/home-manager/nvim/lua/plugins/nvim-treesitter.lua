return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    -- Install parsers for these languages
    local parsers = {
      "lua",
      "vim",
      "vimdoc",
      "python",
      "javascript",
      "typescript",
      "html",
      "css",
      "json",
      "markdown",
    }

    -- Install parsers
    require('nvim-treesitter').install(parsers)
  end,
}
