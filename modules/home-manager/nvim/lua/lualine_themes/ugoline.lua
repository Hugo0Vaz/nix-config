local lualine = require 'lualine'

local sections = {
    lualine_a = 'a',
    lualine_b = 'b',
    lualine_c = 'c',
    lualine_x = 'x',
    lualine_y = 'y',
    lualine_z = 'z'
}

local gruvbox_colors = {
    dark0_hard = '#1d2021',
    dark0 = '#282828',
    dark0_soft = '#32302f',
    dark1 = '#3c3836',
    dark2 = '#504945',
    dark3 = '#665c54',
    dark4 = '#7c6f64',
    gray_245 = '#928374',
    light0_hard = '#f9f5d7',
    light0 = '#fbf1c7',
    light0_soft = '#f2e5bc',
    light1 = '#ebdbb2',
    light2 = '#d5c4a1',
    light3 = '#bdae93',
    light4 = '#a89984',
    bright_red = '#fb4934',
    bright_green = '#b8bb26',
    bright_yellow = '#fabd2f',
    bright_blue = '#83a598',
    bright_purple = '#d3869b',
    bright_aqua = '#8ec07c',
    bright_orange = '#fe8019',
    neutral_red = '#cc241d',
    neutral_green = '#98971a',
    neutral_yellow = '#d79921',
    neutral_blue = '#458588',
    neutral_purple = '#b16286',
    neutral_aqua = '#689d6a',
    neutral_orange = '#d65d0e',
    faded_red = '#9d0006',
    faded_green = '#79740e',
    faded_yellow = '#b57614',
    faded_blue = '#076678',
    faded_purple = '#8f3f71',
    faded_aqua = '#427b58',
    faded_orange = '#af3a03'
}

local mode_colors = {
    n = gruvbox_colors.light4, -- normal
    i = gruvbox_colors.bright_aqua, -- insert
    v = gruvbox_colors.faded_yellow, -- visual by char
    [''] = gruvbox_colors.faded_yellow, -- visual blockwise
    V = gruvbox_colors.faded_yellow, -- visual by line
    c = gruvbox_colors.neutral_orange, -- command-line editing
    no = gruvbox_colors.light4, -- operator-pending
    s = gruvbox_colors.faded_green, -- select by character
    S = gruvbox_colors.faded_yellow, -- select by line
    [''] = gruvbox_colors.faded_yellow, -- select blockwise
    ic = gruvbox_colors.bright_aqua, -- insert mode completion
    R = gruvbox_colors.faded_red, -- replace
    Rv = gruvbox_colors.bright_red, -- virtual replace
    cv = gruvbox_colors.bright_green, -- vim ex mode
    ce = gruvbox_colors.neutral_green, -- normal ex mode
    r = gruvbox_colors.bright_orange, -- hit-enter prompt
    rm = gruvbox_colors.light4, -- the -- more -- prompt
    ['r?'] = gruvbox_colors.faded_blue, -- A |:confirm| query of some sort
    ['!'] = gruvbox_colors.bright_yellow, -- shell or external command is executing
    t = gruvbox_colors.neutral_green -- terminal mode: keys go to the job
}

local conditions = {
    buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand '%:t') ~= 1
    end,
    hide_in_width100 = function() return vim.fn.winwidth(0) > 120 end,
    hide_in_width80 = function() return vim.fn.winwidth(0) > 80 end,
    check_git_workspace = function()
        local filepath = vim.fn.expand '%:p:h'
        local gitdir = vim.fn.finddir('.git', filepath .. ';')
        return gitdir and #gitdir > 0 and #gitdir < #filepath
    end
}

local function fn_mode_color()
    return function()
        return {bg = mode_colors[vim.fn.mode()], fg = gruvbox_colors.dark0}
    end
end

local ugoline_theme = {
    normal = {
        a = fn_mode_color(),
        b = {fg = gruvbox_colors.light0, bg = gruvbox_colors.dark2},
        c = {fg = gruvbox_colors.light0, bg = gruvbox_colors.dark0_soft}
    }
}

local config = {
    options = {
        icons_enabled = true,
        theme = ugoline_theme,
        component_separators = {left = '', right = ''},
        section_separators = {left = '', right = ''},
        disabled_filetypes = {statusline = {'neo-tree'}},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {statusline = 1000, tabline = 1000, winbar = 1000}
    },
    sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
    }
}

local function insert_component_section(section, component)
    if section == 'a' then
        table.insert(config.sections.lualine_a, component)
    elseif section == 'b' then
        table.insert(config.sections.lualine_b, component)
    elseif section == 'c' then
        table.insert(config.sections.lualine_c, component)
    elseif section == 'x' then
        table.insert(config.sections.lualine_x, component)
    elseif section == 'y' then
        table.insert(config.sections.lualine_y, component)
    elseif section == 'z' then
        table.insert(config.sections.lualine_z, component)
    end
end

insert_component_section(sections.lualine_a, {'mode', color = fn_mode_color()})

insert_component_section(sections.lualine_b, {
    'filename',
    file_status = true, -- Displays file status (readonly status, modified status)
    newfile_status = false, -- Display new file status (new file means no write after created)
    shorting_target = 40, -- Shortens path to leave 40 spaces in the window
    symbols = {
        modified = '', -- Text to show when the file is modified.
        readonly = '', -- Text to show when the file is non-modifiable or readonly.
        unnamed = '[no name]', -- Text to show for unnamed buffers.
        newfile = '[new]' -- Text to show for newly created file before first write
    },
    path = 4,
    padding = {left = 3, right = 3},
    cond = conditions.hide_in_width80
})

insert_component_section(sections.lualine_c, {
    'branch',
    icon = '',
    color = {gui = 'bold'},
    cond = conditions.hide_in_width80,
    padding = {left = 2, right = 1}
})

insert_component_section(sections.lualine_c, {
    'diff',
    symbols = {added = ' ', modified = '󰝤 ', removed = ' '},
    diff_color = {
        added = {fg = gruvbox_colors.bright_green},
        modified = {fg = gruvbox_colors.bright_orange},
        removed = {fg = gruvbox_colors.bright_red}
    },
    cond = conditions.hide_in_width100,
    padding = {left = 1, right = 1}
})

insert_component_section(sections.lualine_x, {
    function()
        local msg = 'No Active Lsp'
        local buf_ft = vim.api.nvim_get_option_value('filetype', {buf = 0})
        local clients = vim.lsp.get_clients()
        if next(clients) == nil then return msg end
        for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                return client.name
            end
        end
        return msg
    end,
    icon = ' LSP:',
    color = {fg = '#ffffff', gui = 'bold'},
    padding = {left = 1, right = 1},
    cond = conditions.hide_in_width100
})

insert_component_section(sections.lualine_x, {
    'diagnostics',
    sources = {'nvim_diagnostic'},
    symbols = {error = ' ', warn = ' ', info = ' '},
    diagnostics_color = {
        color_error = {fg = gruvbox_colors.neutral_red},
        color_warn = {fg = gruvbox_colors.bright_yellow},
        color_info = {fg = gruvbox_colors.bright_blue}
    },
    cond = conditions.hide_in_width80,
    padding = {left = 1, right = 2}
})

insert_component_section(sections.lualine_z, {
    'filetype',
    colored = false,
    padding = {left = 1, right = 1},
    cond = conditions.hide_in_width100
})

insert_component_section(sections.lualine_z, {
    'fileformat',
    icons_enabled = false,
    cond = conditions.hide_in_width100
})

insert_component_section(sections.lualine_z,
                         {'encoding', cond = conditions.hide_in_width100})

insert_component_section(sections.lualine_z, {'location'})

lualine.setup(config)
