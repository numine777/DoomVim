if os.getenv "DOOMVIM_RUNTIME_DIR" then
  local path_sep = vim.loop.os_uname().version:match "Windows" and "\\" or "/"
  vim.opt.rtp:append(os.getenv "DOOMVIM_RUNTIME_DIR" .. path_sep .. "dvim")
end

require("dvim.bootstrap"):init()

require("dvim.config"):load()

local plugins = require "dvim.plugins"
require("dvim.plugin-loader"):load { plugins, dvim.plugins }

local Log = require "dvim.core.log"
Log:debug "Starting DoomVim"

vim.g.colors_name = dvim.colorscheme -- Colorscheme must get called after plugins are loaded or it will break new installs.
vim.cmd("colorscheme " .. dvim.colorscheme)

local commands = require "dvim.core.commands"
commands.load(commands.defaults)

require("dvim.keymappings").setup()

require("dvim.lsp").setup()
