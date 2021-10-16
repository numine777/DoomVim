return {
  leader = "space",
  colorscheme = "gruvbox",
  line_wrap_cursor_movement = true,
  transparent_window = true,
  format_on_save = false,
  keys = {},

  builtin = {},

  log = {
    ---@usage can be { "trace", "debug", "info", "warn", "error", "fatal" },
    level = "warn",
    viewer = {
      ---@usage this will fallback on "less +F" if not found
      cmd = "lnav",
      layout_config = {
        ---@usage direction = 'vertical' | 'horizontal' | 'window' | 'float',
        direction = "horizontal",
        open_mapping = "",
        size = 40,
        float_opts = {},
      },
    },
  },
  plugins = {
    -- use config.lua for this not put here
  },

  autocommands = {},
  lang = {},
}
