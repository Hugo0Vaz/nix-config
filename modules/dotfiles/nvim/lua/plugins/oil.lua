return {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = {{"echasnovski/mini.icons", opts = {}}},
    config = function ()
        require("oil").setup()
        vim.keymap.set("n", "<leader>bo", "<CMD>Oil<CR>", { desc = "Open [B]uffer of [O]il" })
    end
}
