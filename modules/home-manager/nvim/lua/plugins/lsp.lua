local function setup_lua_ls()
  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
        },
        telemetry = {
          enable = false,
        },
      },
    },
  })
end

return {
  "neovim/nvim-lspconfig",
  config = function()
    -- Keymaps on LSP attach
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, {
            buffer = event.buf,
            desc = "LSP: " .. desc,
          })
        end

        local telescope = require("telescope.builtin")

        map("gd", telescope.lsp_definitions, "[G]oto [D]efinition")
        map("gr", telescope.lsp_references, "[G]oto [R]eferences")
        map("gI", telescope.lsp_implementations, "[G]oto [I]mplementation")
        map("<leader>D", telescope.lsp_type_definitions, "Type [D]efinition")
        map("<leader>ds", telescope.lsp_document_symbols, "[D]ocument [S]ymbols")
        map("<leader>ws", telescope.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        map("K", vim.lsp.buf.hover, "Hover Documentation")
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        -- Document highlight
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = event.buf,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end,
    })

    -- Capabilities (cmp-nvim-lsp)
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend(
      "force",
      capabilities,
      require("cmp_nvim_lsp").default_capabilities()
    )

    vim.lsp.enable('nil_ls')
    vim.lsp.enable('phpactor')
    vim.lsp.enable('gopls')
    vim.lsp.enable('pyright')
    vim.lsp.enable('ts_ls')
    vim.lsp.enable('rust_analyzer')
  end,
}
