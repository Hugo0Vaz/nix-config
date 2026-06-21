vim.pack.add({"https://github.com/lewis6991/gitsigns.nvim"})

require('gitsigns').setup {
  signs = {
    add          = { text = '▎' },
    change       = { text = '▎' },
    delete       = { text = '▁' },
    topdelete    = { text = '▔' },
    changedelete = { text = '~' },
    untracked    = { text = '▎' },
  },
  signs_staged = {
    add          = { text = '▎' },
    change       = { text = '▎' },
    delete       = { text = '▁' },
    topdelete    = { text = '▔' },
    changedelete = { text = '~' },
    untracked    = { text = '▎' },
  },
  signs_staged_enable = true,
  signcolumn = true,
  numhl      = false,
  linehl     = false,
  word_diff  = false,
  watch_gitdir = {
    follow_files = true,
  },
  auto_attach = true,
  attach_to_untracked = false,
  current_line_blame = false,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol',
    delay = 1000,
    ignore_whitespace = false,
    virt_text_priority = 100,
    use_focus = true,
  },
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
  sign_priority = 6,
  update_debounce = 200,
  max_file_length = 40000,
  preview_config = {
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1,
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, lhs, rhs, opts)
      opts = vim.tbl_extend('force', { buffer = bufnr }, opts or {})
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Navigation
    map('n', ']h', function()
      if vim.wo.diff then return ']h' end
      vim.schedule(function() gs.nav_hunk('next') end)
      return '<Ignore>'
    end, { expr = true, desc = 'Next hunk' })

    map('n', '[h', function()
      if vim.wo.diff then return '[h' end
      vim.schedule(function() gs.nav_hunk('prev') end)
      return '<Ignore>'
    end, { expr = true, desc = 'Previous hunk' })

    -- Actions
    map('n', '<leader>hs', gs.stage_hunk, { desc = 'Stage hunk' })
    map('n', '<leader>hr', gs.reset_hunk, { desc = 'Reset hunk' })
    map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
      { desc = 'Stage selected hunks' })
    map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
      { desc = 'Reset selected hunks' })
    map('n', '<leader>hS', gs.stage_buffer, { desc = 'Stage buffer' })
    map('n', '<leader>hR', gs.reset_buffer, { desc = 'Reset buffer' })
    map('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview hunk' })
    map('n', '<leader>hP', gs.preview_hunk_inline, { desc = 'Preview hunk inline' })

    -- Blame
    map('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = 'Blame line (full)' })

    -- Toggle blame line
    map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = '[T]oggle [b]lame line' })

    -- Toggle signs
    map('n', '<leader>ts', gs.toggle_signs, { desc = 'Toggle signs' })

    -- Text object
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select hunk' })
  end,
}
