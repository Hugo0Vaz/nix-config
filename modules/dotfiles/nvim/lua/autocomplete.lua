vim.pack.add({
	"https://github.com/saghen/blink.cmp",
	"https://github.com/saghen/blink.lib",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/L3MON4D3/LuaSnip",
})

require("blink.cmp").setup({
	snippets = { preset = "luasnip" },

	keymap = {
		preset = "none",
		["<C-n>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "select_and_accept", "fallback" },
		["<S-Tab>"] = { "select_prev", "fallback" },
		["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-y>"] = { "select_and_accept", "fallback" },
		["<C-e>"] = { "hide" },
	},

	appearance = {
		nerd_font_variant = "mono",
	},

	completion = {
		documentation = { auto_show = false },
		trigger = {
			show_on_keyword = true,
			show_on_trigger_character = true,
		},
	},

	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},

	-- Lua implementation instead of native Rust (no cargo needed)
	fuzzy = { implementation = "lua" },
})

-- Load friendly-snippets into LuaSnip
require("luasnip.loaders.from_vscode").lazy_load()
