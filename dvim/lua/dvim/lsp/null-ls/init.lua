local M = {}

local Log = require "dvim.core.log"
local formatters = require "dvim.lsp.null-ls.formatters"
local linters = require "dvim.lsp.null-ls.linters"

function M:setup()
  local status_ok, null_ls = pcall(require, "null-ls")
  if not status_ok then
    Log:error "Missing null-ls dependency"
    return
  end

  null_ls.config()
  local default_opts = require("dvim.lsp").get_common_opts()

  if vim.tbl_isempty(dvim.lsp.null_ls.setup or {}) then
    dvim.lsp.null_ls.setup = default_opts
  end

  require("lspconfig")["null-ls"].setup(dvim.lsp.null_ls.setup)
  for filetype, config in pairs(dvim.lang) do
    if not vim.tbl_isempty(config.formatters) then
      vim.tbl_map(function(c)
        c.filetypes = { filetype }
      end, config.formatters)
      formatters.setup(config.formatters)
    end
    if not vim.tbl_isempty(config.linters) then
      vim.tbl_map(function(c)
        c.filetypes = { filetype }
      end, config.formatters)
      linters.setup(config.linters)
    end
  end
end

return M
