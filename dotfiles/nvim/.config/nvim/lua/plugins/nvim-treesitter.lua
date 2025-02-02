return { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
        -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
        local parser_config =
            require('nvim-treesitter.parsers').get_parser_configs()
        parser_config.blade = {
            install_info = {
                url = 'https://github.com/EmranMR/tree-sitter-blade',
                files = {'src/parser.c'},
                branch = 'main'
            },
            filetype = 'blade'
        }

        ---@diagnostic disable-next-line: missing-fields
        require('nvim-treesitter.configs').setup {
            ensure_installed = {
                'bash', 'c', 'html', 'lua', 'markdown', 'vim', 'vimdoc', 'php',
                'blade', 'json', 'yaml', 'dockerfile', 'templ'
            },
            -- Autoinstall languages that are not installed
            auto_install = true,
            highlight = {enable = true},
            indent = {enable = true}
        }
    end
}
