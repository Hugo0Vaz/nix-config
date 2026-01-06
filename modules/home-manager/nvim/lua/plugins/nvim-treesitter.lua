return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  priority = 100,
  config = function()
    -- Install parsers for these languages
    local install = require('nvim-treesitter').install({
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
      "bash",
      "c",
      "nix",
      "cpp"
    })

    -- Don't wait for installation to complete, let it happen in background
    if install and install.wait then
      vim.defer_fn(function()
        install:wait(60000) -- wait max 1 minute
      end, 100)
    end
  end,
}
