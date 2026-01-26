return {
  "neovim/nvim-lspconfig",
  event = "BufReadPre",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    -- Enhanced capabilities with all features enabled
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    
    -- Enable snippet support
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.resolveSupport = {
      properties = { "documentation", "detail", "additionalTextEdits" },
    }
    
    -- Enable all cmp_nvim_lsp capabilities
    capabilities = vim.tbl_deep_extend(
      "force",
      capabilities,
      require("cmp_nvim_lsp").default_capabilities()
    )
    
    -- Enable inlay hints, code lens, and semantic tokens
    capabilities.textDocument.codeLens = { dynamicRegistration = true }
    capabilities.textDocument.inlayHint = {
      dynamicRegistration = true,
      resolveSupport = { properties = { "textEdits", "tooltip", "location", "command" } },
    }
    capabilities.textDocument.semanticTokens = {
      dynamicRegistration = true,
      requests = {
        full = { delta = true },
        range = true,
      },
    }

    -- Keymaps on LSP attach
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, {
            buffer = event.buf,
            desc = "LSP: " .. desc,
          })
        end

        local telescope = require("telescope.builtin")

        -- Navigation
        map("gd", telescope.lsp_definitions, "[G]oto [D]efinition")
        map("gr", telescope.lsp_references, "[G]oto [R]eferences")
        map("gI", telescope.lsp_implementations, "[G]oto [I]mplementation")
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
        map("<leader>D", telescope.lsp_type_definitions, "Type [D]efinition")
        
        -- Symbols
        map("<leader>ds", telescope.lsp_document_symbols, "[D]ocument [S]ymbols")
        map("<leader>ws", telescope.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
        
        -- Actions
        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        map("K", vim.lsp.buf.hover, "Hover Documentation")
        map("<leader>K", vim.lsp.buf.signature_help, "Signature Help")
        
        -- Inlay hints toggle
        map("<leader>th", function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, "[T]oggle Inlay [H]ints")

        -- Code lens
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.codeLensProvider then
          map("<leader>cl", vim.lsp.codelens.run, "[C]ode [L]ens")
          
          -- Auto-refresh code lens
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = event.buf,
            callback = vim.lsp.codelens.refresh,
          })
        end

        -- Document highlight
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
        
        -- Enable inlay hints by default if supported
        if client and client.server_capabilities.inlayHintProvider then
          vim.lsp.inlay_hint.enable(true)
        end
      end,
    })

    -- Server configurations
    local servers = {
      -- Nix
      nil_ls = {
        settings = {
          ["nil"] = {
            formatting = { command = { "nixfmt" } },
            nix = { flake = { autoArchive = true } },
          },
        },
      },
      
      -- Lua
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
            hint = {
              enable = true,
              setType = true,
              paramName = "All",
              paramType = true,
              arrayIndex = "Enable",
            },
          },
        },
      },
      
      -- PHP
      phpactor = {
        init_options = {
          ["language_server_phpstan.enabled"] = true,
          ["language_server_psalm.enabled"] = false,
        },
      },
      
      -- Go
      gopls = {
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
            gofumpt = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      },
      
      -- Rust
      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
            },
            checkOnSave = {
              command = "clippy",
            },
            procMacro = {
              enable = true,
            },
            inlayHints = {
              bindingModeHints = { enable = true },
              chainingHints = { enable = true },
              closingBraceHints = { enable = true, minLines = 25 },
              closureReturnTypeHints = { enable = "always" },
              lifetimeElisionHints = { enable = "always", useParameterNames = true },
              parameterHints = { enable = true },
              typeHints = { enable = true },
            },
          },
        },
      },
      
      -- TypeScript/JavaScript
      ts_ls = {
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      },
      
      -- HTML
      html = {},
      
      -- CSS
      cssls = {
        settings = {
          css = {
            validate = true,
            lint = {
              unknownAtRules = "ignore",
            },
          },
          scss = {
            validate = true,
            lint = {
              unknownAtRules = "ignore",
            },
          },
          less = {
            validate = true,
            lint = {
              unknownAtRules = "ignore",
            },
          },
        },
      },
      
      -- Tailwind CSS
      tailwindcss = {
        filetypes = {
          "html",
          "css",
          "scss",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "vue",
          "svelte",
          "blade",
          "php",
        },
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                {"cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"},
                {"cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)"},
              },
            },
          },
        },
      },
      
      -- Python
      pyright = {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "workspace",
              useLibraryCodeForTypes = true,
              typeCheckingMode = "basic",
            },
          },
        },
      },
    }

    -- Enable all servers with their configurations
    for server, config in pairs(servers) do
      local server_config = vim.tbl_deep_extend("force", {
        capabilities = vim.deepcopy(capabilities),
      }, config)
      
      -- Configure the server first
      if next(server_config) ~= nil then
        vim.lsp.config(server, server_config)
      end
      
      -- Enable the server with error handling
      local ok, err = pcall(vim.lsp.enable, server)
      if not ok then
        vim.notify("Failed to enable LSP server: " .. server .. "\n" .. err, vim.log.levels.WARN)
      end
    end
  end,
}
