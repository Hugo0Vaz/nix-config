vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

-- Base LSP capabilities with blink.cmp enhancements (snippet, completion, etc.)
local capabilities = require("blink.cmp").get_lsp_capabilities()

-- Additional capabilities: inlay hints, code lens, semantic tokens
capabilities.textDocument.codeLens = { dynamicRegistration = true }
capabilities.textDocument.inlayHint = {
	dynamicRegistration = true,
	resolveSupport = { properties = { "textEdits", "tooltip", "location", "command" } },
}
capabilities.textDocument.semanticTokens =
	vim.tbl_deep_extend("force", capabilities.textDocument.semanticTokens or {}, {
		dynamicRegistration = true,
		requests = {
			full = { delta = true },
			range = true,
		},
	})

-- Lua LS
vim.lsp.config("lua_ls", {
	capabilities = capabilities,
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
			},
		},
	},
})
vim.lsp.enable("lua_ls")

-- Other servers
local servers = { "nixd", "phpactor", "gopls", "rust_analyzer", "ts_ls", "html", "tailwindcss", "pyright" }
for _, server in ipairs(servers) do
	vim.lsp.config(server, { capabilities = capabilities })
	vim.lsp.enable(server)
end

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
				callback = function()
					vim.lsp.codelens.enable(true, { bufnr = event.buf })
				end,
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
			vim.lsp.inlay_hint.enable(false)
		end
	end,
})
