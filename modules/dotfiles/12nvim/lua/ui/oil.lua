vim.pack.add({'https://github.com/stevearc/oil.nvim'})

local oil = require('oil')

oil.setup {
  -- Oil takes over directory buffers (e.g. `vim .` or `:e src/`)
  default_file_explorer = true,

  columns = {
    'icon',
    'permissions',
    'size',
    'mtime',
  },

  -- Buffer-local options for oil buffers
  buf_options = {
    buflisted = false,
    bufhidden = 'hide',
  },

  -- Window-local options for oil buffers
  win_options = {
    wrap = false,
    signcolumn = 'no',
    cursorcolumn = false,
    foldcolumn = '0',
    spell = false,
    list = false,
    conceallevel = 3,
    concealcursor = 'nvic',
  },

  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  prompt_save_on_select_new_entry = true,
  cleanup_delay_ms = 2000,

  lsp_file_methods = {
    enabled = true,
    timeout_ms = 1000,
    autosave_changes = false,
  },

  constrain_cursor = 'editable',
  watch_for_changes = true,

  -- Custom keymaps inside oil buffers
  keymaps = {
    ['g?'] = { 'actions.show_help', mode = 'n' },
    ['<CR>'] = 'actions.select',
    ['<C-s>'] = { 'actions.select', opts = { vertical = true } },
    ['<C-v>'] = { 'actions.select', opts = { horizontal = true } },
    ['<C-t>'] = { 'actions.select', opts = { tab = true } },
    ['<C-p>'] = 'actions.preview',
    ['<C-c>'] = { 'actions.close', mode = 'n' },
    ['<C-l>'] = 'actions.refresh',
    ['-'] = { 'actions.parent', mode = 'n' },
    ['_'] = { 'actions.open_cwd', mode = 'n' },
    ['`'] = { 'actions.cd', mode = 'n' },
    ['~'] = { 'actions.cd', opts = { scope = 'tab' }, mode = 'n' },
    ['gs'] = { 'actions.change_sort', mode = 'n' },
    ['gx'] = 'actions.open_external',
    ['g.'] = { 'actions.toggle_hidden', mode = 'n' },
    ['g\\'] = { 'actions.toggle_trash', mode = 'n' },
  },
  use_default_keymaps = true,

  view_options = {
    show_hidden = false,
    is_hidden_file = function(name, _)
      return name:match('^%.') ~= nil
    end,
    is_always_hidden = function(_, _)
      return false
    end,
    natural_order = 'fast',
    case_insensitive = false,
    sort = {
      { 'type', 'asc' },
      { 'name', 'asc' },
    },
  },

  -- Configuration for the floating window (used by toggle_float / open_float)
  float = {
    padding = 2,
    max_width = 60,
    max_height = 30,
    border = 'rounded',
    win_options = {
      winblend = 0,
    },
    preview_split = 'auto',
  },

  preview_win = {
    update_on_cursor_moved = true,
    preview_method = 'fast_scratch',
    disable_preview = function(_)
      return false
    end,
    win_options = {},
  },

  confirmation = {
    max_width = 0.9,
    min_width = { 40, 0.4 },
    max_height = 0.9,
    min_height = { 5, 0.1 },
    border = 'rounded',
    win_options = {
      winblend = 0,
    },
  },

  -- Auto git add/mv/rm when operating on files
  git = {
    add = function(_)
      return false
    end,
    mv = function(_, _)
      return false
    end,
    rm = function(_)
      return false
    end,
  },
}

-- Global toggle: open oil as a floating window (neo-tree-style)
vim.keymap.set('n', '<leader>-', function()
  oil.open_float()
end, { desc = 'Open file explorer (Oil)' })

-- Open oil in the parent directory of the current file
vim.keymap.set('n', '<leader>fp', function()
  oil.open()
end, { desc = 'Open Oil in parent directory' })
