
local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.default_prog = { "bash" }
config.font_size = 10.0

config.color_scheme = "Gruvbox Dark (Gogh)"
return config
