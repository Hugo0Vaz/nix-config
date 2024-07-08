-- Neorg is a bit shize to install
-- follow the installation for luarocks.nvim
return {
  'nvim-neorg/neorg',
  dependencies = { 'luarocks.nvim' },
  lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
  version = '*', -- Pin Neorg to the latest stable release
  config = function()
    require('neorg').setup {
      load = {
        ['core.defaults'] = {},
        ['core.concealer'] = {},
        ['core.completion'] = {
          config = {
            engine = 'nvim-cmp',
          },
        },
        ['core.integrations.nvim-cmp'] = {},
        ['core.dirman'] = {
          config = {
            workspaces = {
              my_ws = '~/neorg', -- Format: <name_of_workspace> = <path_to_workspace_root>
              my_other_notes = '~/work/notes',
            },
            index = 'index.norg', -- The name of the main (root) .norg file
          },
        },
      },
    }
  end,
}
