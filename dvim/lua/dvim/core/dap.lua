local M = {}

M.config = function()
  dvim.builtin.dap = {
    active = false,
    on_config_done = nil,
    breakpoint = {
      text = "",
      texthl = "LspDiagnosticsSignError",
      linehl = "",
      numhl = "",
    },
    breakpoint_rejected = {
      text = "",
      texthl = "LspDiagnosticsSignHint",
      linehl = "",
      numhl = "",
    },
    stopped = {
      text = "",
      texthl = "LspDiagnosticsSignInformation",
      linehl = "DiagnosticUnderlineInfo",
      numhl = "LspDiagnosticsSignInformation",
    },
  }
end

M.setup = function()
  local dap = require "dap"

  vim.fn.sign_define("DapBreakpoint", dvim.builtin.dap.breakpoint)
  vim.fn.sign_define("DapBreakpointRejected", dvim.builtin.dap.breakpoint_rejected)
  vim.fn.sign_define("DapStopped", dvim.builtin.dap.stopped)

  dap.defaults.fallback.terminal_win_cmd = "50vsplit new"

  dvim.keys.normal_mode["<leader>dbp"] = "<cmd>lua require'dap'.toggle_breakpoint()<cr>"
  dvim.keys.normal_mode["<leader>dbb"] = "<cmd>lua require'dap'.step_back()<cr>"
  dvim.keys.normal_mode["<leader>dbc"] = "<cmd>lua require'dap'.continue()<cr>"
  dvim.keys.normal_mode["<leader>dbC"] = "<cmd>lua require'dap'.run_to_cursor()<cr>"
  dvim.keys.normal_mode["<leader>dbd"] = "<cmd>lua require'dap'.disconnect()<cr>"
  dvim.keys.normal_mode["<leader>dbg"] = "<cmd>lua require'dap'.session()<cr>"
  dvim.keys.normal_mode["<leader>dbi"] = "<cmd>lua require'dap'.step_into()<cr>"
  dvim.keys.normal_mode["<leader>dbo"] = "<cmd>lua require'dap'.step_over()<cr>"
  dvim.keys.normal_mode["<leader>dbu"] = "<cmd>lua require'dap'.step_out()<cr>"
  dvim.keys.normal_mode["<leader>dbp"] = "<cmd>lua require'dap'.pause.toggle()<cr>"
  dvim.keys.normal_mode["<leader>dbr"] = "<cmd>lua require'dap'.repl.toggle()<cr>"
  dvim.keys.normal_mode["<leader>dbs"] = "<cmd>lua require'dap'.continue()<cr>"
  dvim.keys.normal_mode["<leader>dbq"] = "<cmd>lua require'dap'.close()<cr>"

  if dvim.builtin.dap.on_config_done then
    dvim.builtin.dap.on_config_done(dap)
  end
end

-- TODO put this up there ^^^ call in ftplugin

-- M.dap = function()
--   if dvim.plugin.dap.active then
--     local dap_install = require "dap-install"
--     dap_install.config("python_dbg", {})
--   end
-- end
--
-- M.dap = function()
--   -- gem install readapt ruby-debug-ide
--   if dvim.plugin.dap.active then
--     local dap_install = require "dap-install"
--     dap_install.config("ruby_vsc_dbg", {})
--   end
-- end

return M
