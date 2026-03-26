return {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = 'master',
    dependencies = {
        'nvim-lua/plenary.nvim', {
            'nvim-telescope/telescope-fzf-native.nvim',

            build = 'make',
            cond = function() return vim.fn.executable 'make' == 1 end
        }, {'nvim-telescope/telescope-ui-select.nvim'},
        {'benfowler/telescope-luasnip.nvim'}, {'nvim-tree/nvim-web-devicons'}
    },
    config = function()
        -- [[ Configure Telescope ]]
        -- See `:help telescope` and `:help telescope.setup()`

        -- Workaround for treesitter ft_to_lang compatibility issue
        local ts_utils = require('telescope.previewers.utils')
        local old_ts_highlighter = ts_utils.ts_highlighter
        ts_utils.ts_highlighter = function(bufnr, ft, opts)
            -- Check if the treesitter API is available
            if vim.treesitter.language and vim.treesitter.language.get_lang then
                -- Use new API
                local lang = vim.treesitter.language.get_lang(ft)
                if lang and pcall(vim.treesitter.start, bufnr, lang) then
                    return
                end
            end
            -- Fall back to regex highlighting
            pcall(vim.api.nvim_set_option_value, 'syntax', ft, { buf = bufnr })
        end

        require('telescope').setup {
            defaults = {file_ignore_patterns = {'.git', 'node_modules'}},
            extensions = {
                ['ui-select'] = {require('telescope.themes').get_dropdown()}
            },
            pickers = {find_files = {hidden = true}}
        }

        -- Enable telescope extensions, if they are installed
        pcall(require('telescope').load_extension, 'fzf')
        pcall(require('telescope').load_extension, 'ui-select')
        pcall(require('telescope').load_extension, 'luasnip')

        -- See `:help telescope.builtin`
        local builtin = require 'telescope.builtin'
        vim.keymap.set('n', '<leader>sh', builtin.help_tags,
                       {desc = '[S]earch [H]elp'})
        vim.keymap.set('n', '<leader>sk', builtin.keymaps,
                       {desc = '[S]earch [K]eymaps'})
        vim.keymap.set('n', '<leader>sf', builtin.find_files,
                       {desc = '[S]earch [F]iles'})
        vim.keymap.set('n', '<leader>ss', builtin.builtin,
                       {desc = '[S]earch [S]elect Telescope'})
        vim.keymap.set('n', '<leader>sw', builtin.grep_string,
                       {desc = '[S]earch current [W]ord'})
        vim.keymap.set('n', '<leader>sg', builtin.live_grep,
                       {desc = '[S]earch by [G]rep'})
        vim.keymap.set('n', '<leader>sd', builtin.diagnostics,
                       {desc = '[S]earch [D]iagnostics'})
        vim.keymap.set('n', '<leader>sr', builtin.resume,
                       {desc = '[S]earch [R]esume'})
        vim.keymap.set('n', '<leader>s.', builtin.oldfiles,
                       {desc = '[S]earch Recent Files ("." for repeat)'})
        vim.keymap.set('n', '<leader><leader>', builtin.buffers,
                       {desc = '[ ] Find existing buffers'})

        vim.keymap.set('n', '<leader>/', function()
            builtin.current_buffer_fuzzy_find(
                require('telescope.themes').get_dropdown {
                    winblend = 10,
                    previewer = false
                })
        end, {desc = '[/] Fuzzily search in current buffer'})

        vim.keymap.set('n', '<leader>s/', function()
            builtin.live_grep {
                grep_open_files = true,
                prompt_title = 'Live Grep in Open Files'
            }
        end, {desc = '[S]earch [/] in Open Files'})

        -- Shortcut for searching your neovim configuration files
        vim.keymap.set('n', '<leader>sn', function()
            builtin.find_files {cwd = vim.fn.stdpath 'config'}
        end, {desc = '[S]earch [N]eovim files'})
    end
}
