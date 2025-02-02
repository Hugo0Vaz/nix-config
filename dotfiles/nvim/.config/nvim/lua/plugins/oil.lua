return {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = {{"echasnovski/mini.icons", opts = {}}},
    config = function ()
        vim.keymap.set("n", "<leader>fo", "<CMD>Oil<CR>", { desc = "Edit [F]iles in [O]il" })
    end
}
