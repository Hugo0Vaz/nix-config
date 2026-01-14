return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  priority = 1000,
  -- Remove textobjects dependency until needed
  -- dependencies = {
  --   "nvim-treesitter/nvim-treesitter-textobjects",
  -- },
  config = function()
    -- Setup nvim-treesitter with parsers to install
    require("nvim-treesitter").setup({
      -- Directory to install parsers to (defaults to stdpath('data')/site)
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    -- Install parsers
    require("nvim-treesitter").install({
      "bash",
      "c",
      "cpp",
      "css",
      "go",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "nix",
      "python",
      "query",
      "regex",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
    })

    -- -- Setup textobjects (still uses old config API)
    -- require("nvim-treesitter.configs").setup({
    --   textobjects = {
    --     select = {
    --       enable = true,
    --       lookahead = true,
    --       keymaps = {
    --         ["af"] = "@function.outer",
    --         ["if"] = "@function.inner",
    --         ["ac"] = "@class.outer",
    --         ["ic"] = "@class.inner",
    --       },
    --     },
    --     move = {
    --       enable = true,
    --       set_jumps = true,
    --       goto_next_start = {
    --         ["]f"] = "@function.outer",
    --         ["]c"] = "@class.outer",
    --       },
    --       goto_next_end = {
    --         ["]F"] = "@function.outer",
    --         ["]C"] = "@class.outer",
    --       },
    --       goto_previous_start = {
    --         ["[f"] = "@function.outer",
    --         ["[c"] = "@class.outer",
    --       },
    --       goto_previous_end = {
    --         ["[F"] = "@function.outer",
    --         ["[C"] = "@class.outer",
    --       },
    --     },
    --   },
    -- })
    --
    -- Enable treesitter features for installed languages
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "bash",
        "c",
        "cpp",
        "css",
        "go",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "nix",
        "python",
        "rust",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      },
      callback = function()
        -- Syntax highlighting (provided by Neovim)
        vim.treesitter.start()

        -- Folds (provided by Neovim)
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo[0][0].foldmethod = "expr"

        -- Indentation (provided by nvim-treesitter, experimental)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    -- Incremental selection keymaps
    vim.keymap.set("n", "<C-space>", function()
      require("nvim-treesitter.incremental_selection").init_selection()
    end, { desc = "Treesitter: Init selection" })

    vim.keymap.set("x", "<C-space>", function()
      require("nvim-treesitter.incremental_selection").node_incremental()
    end, { desc = "Treesitter: Increment node" })

    vim.keymap.set("x", "<bs>", function()
      require("nvim-treesitter.incremental_selection").node_decremental()
    end, { desc = "Treesitter: Decrement node" })
  end,
}
