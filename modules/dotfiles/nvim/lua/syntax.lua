-- [[ Treesitter: syntax highlighting, folding, indentation, incremental selection ]]

-- Language aliases (e.g. .sh files use bash parser) — built-in, no plugin needed
vim.treesitter.language.register("bash", "sh")
vim.treesitter.language.add("rust")
vim.treesitter.language.add("python")
vim.treesitter.language.add("markdown")

vim.treesitter.language.add("bash")
vim.treesitter.language.add("c")
vim.treesitter.language.add("cpp")
vim.treesitter.language.add("css")
vim.treesitter.language.add("go")
vim.treesitter.language.add("html")
vim.treesitter.language.add("javascript")
vim.treesitter.language.add("json")
vim.treesitter.language.add("lua")
vim.treesitter.language.add("markdown")
vim.treesitter.language.add("nix")
vim.treesitter.language.add("python")
vim.treesitter.language.add("regex")
vim.treesitter.language.add("rust")
vim.treesitter.language.add("tsx")
vim.treesitter.language.add("typescript")
vim.treesitter.language.add("vim")
vim.treesitter.language.add("vimdoc")
vim.treesitter.language.add("yaml")

-- Treesitter-based code folding (global defaults) — built-in, no plugin needed
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 10
vim.opt.foldnestmax = 15

-- Ensure treesitter highlighting starts for every buffer — built-in
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter-highlight", { clear = true }),
	pattern = "*",
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})

-- nvim-treesitter plugin (parser management, indent, incremental selection)
-- These features depend on the plugin being cloned + loaded, so we defer.
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

vim.schedule(function()
	local ok, ts_configs = pcall(require, "nvim-treesitter.configs")
	if not ok then
		-- vim.notify_once('nvim-treesitter not ready yet — run :TSUpdate on next startup', vim.log.levels.WARN)
		return
	end

	ts_configs.setup({
		-- Syntax highlighting (wraps Neovim's built-in treesitter)
		highlight = {
			enable = true,
			-- Disable for large files to avoid performance issues
			disable = function(_, bufnr)
				local max_filesize = 100 * 1024 -- 100 KiB
				local ok_stats, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
				if ok_stats and stats and stats.size > max_filesize then
					return true
				end
			end,
		},

		-- Treesitter-based indentation (experimental)
		indent = { enable = true },

		-- Incremental selection: <C-space> to expand node, <bs> to shrink
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<C-space>",
				node_incremental = "<C-space>",
				node_decremental = "<bs>",
			},
		},
	})
end)

-- Parser list kept as a comment for quick reference (use :TSInstall <lang>)
-- Currently needed: bash, c, cpp, css, go, html, javascript, json, lua,
-- markdown, markdown_inline, nix, python, query, regex, rust, tsx,
-- typescript, vim, vimdoc, yaml
