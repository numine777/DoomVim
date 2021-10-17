local utils = require "dvim.utils"
local Log = require "dvim.core.log"

local M = {}
local user_config_dir = get_config_dir()
local user_config_file = utils.join_paths(user_config_dir, "config.lua")

---Get the full path to the user configuration file
---@return string
function M:get_user_config_path()
  return user_config_file
end

--- Initialize dvim default configuration
-- Define dvim global variable
function M:init()
  if vim.tbl_isempty(dvim or {}) then
    dvim = require "dvim.config.defaults"
    local home_dir = vim.loop.os_homedir()
    dvim.vsnip_dir = utils.join_paths(home_dir, ".config", "snippets")
    dvim.database = { save_location = utils.join_paths(home_dir, ".config", "doomvim_db"), auto_execute = 1 }
  end

  local builtins = require "dvim.core.builtins"
  builtins.config { user_config_file = user_config_file }

  local settings = require "dvim.config.settings"
  settings.load_options()

  local dvim_lsp_config = require "dvim.lsp.config"
  dvim.lsp = vim.deepcopy(dvim_lsp_config)

  local supported_languages = {
    "asm",
    "bash",
    "beancount",
    "bibtex",
    "bicep",
    "c",
    "c_sharp",
    "clojure",
    "cmake",
    "comment",
    "commonlisp",
    "cpp",
    "crystal",
    "cs",
    "css",
    "cuda",
    "d",
    "dart",
    "dockerfile",
    "dot",
    "elixir",
    "elm",
    "emmet",
    "erlang",
    "fennel",
    "fish",
    "fortran",
    "gdscript",
    "glimmer",
    "go",
    "gomod",
    "graphql",
    "haskell",
    "hcl",
    "heex",
    "html",
    "java",
    "javascript",
    "javascriptreact",
    "jsdoc",
    "json",
    "json5",
    "jsonc",
    "julia",
    "kotlin",
    "latex",
    "ledger",
    "less",
    "lua",
    "markdown",
    "nginx",
    "nix",
    "ocaml",
    "ocaml_interface",
    "perl",
    "php",
    "pioasm",
    "ps1",
    "puppet",
    "python",
    "ql",
    "query",
    "r",
    "regex",
    "rst",
    "ruby",
    "rust",
    "scala",
    "scss",
    "sh",
    "solidity",
    "sparql",
    "sql",
    "supercollider",
    "surface",
    "svelte",
    "swift",
    "tailwindcss",
    "terraform",
    "tex",
    "tlaplus",
    "toml",
    "tsx",
    "turtle",
    "typescript",
    "typescriptreact",
    "verilog",
    "vim",
    "vue",
    "yaml",
    "yang",
    "zig",
  }

  require("dvim.lsp.manager").init_defaults(supported_languages)
end

local function deprecation_notice()
  local in_headless = #vim.api.nvim_list_uis() == 0
  if in_headless then
    return
  end

  for lang, entry in pairs(dvim.lang) do
    local deprecated_config = entry["dvim.lsp"] or {}
    if not vim.tbl_isempty(deprecated_config) then
      local msg = string.format(
        "Deprecation notice: [dvim.lang.%s.lsp] setting is no longer supported. See https://github.com/DoomVim/DoomVim#breaking-changes",
        lang
      )
      vim.schedule(function()
        vim.notify(msg, vim.log.levels.WARN)
      end)
    end
  end
end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:load(config_path)
  local autocmds = require "dvim.core.autocmds"
  config_path = config_path or self.get_user_config_path()
  local ok, err = pcall(dofile, config_path)
  if not ok then
    if utils.is_file(user_config_file) then
      Log:warn("Invalid configuration: " .. err)
    else
      Log:warn(string.format("Unable to find configuration file [%s]", config_path))
    end
  end

  deprecation_notice()

  autocmds.define_augroups(dvim.autocommands)

  local settings = require "dvim.config.settings"
  settings.load_commands()
end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:reload()
  local dvim_modules = {}
  for module, _ in pairs(package.loaded) do
    if module:match "dvim" then
      package.loaded.module = nil
      table.insert(dvim_modules, module)
    end
  end

  M:init()
  M:load()

  require("dvim.keymappings").setup() -- this should be done before loading the plugins
  local plugins = require "dvim.plugins"
  utils.toggle_autoformat()
  local plugin_loader = require "dvim.plugin-loader"
  plugin_loader:cache_reset()
  plugin_loader:load { plugins, dvim.plugins }
  vim.cmd ":PackerInstall"
  vim.cmd ":PackerCompile"
  -- vim.cmd ":PackerClean"
  require("dvim.lsp").setup()
  Log:info "Reloaded configuration"
end

return M
