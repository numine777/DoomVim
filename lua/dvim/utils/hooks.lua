local M = {}

local Log = require "dvim.core.log"
local in_headless = #vim.api.nvim_list_uis() == 0

function M.run_pre_update()
  Log:debug "Starting pre-update hook"
  _G.__luacache.clear_cache()
end

---Reset any startup cache files used by Packer and Impatient
---It also forces regenerating any template ftplugin files
---Tip: Useful for clearing any outdated settings
function M.reset_cache()
  _G.__luacache.clear_cache()
  require("dvim.plugin-loader"):cache_reset()
  package.loaded["dvim.lsp.templates"] = nil
  require("dvim.lsp.templates").generate_templates()
end

function M.run_post_update()
  Log:debug "Starting post-update hook"
  M.reset_cache()

  if not in_headless then
    vim.schedule(function()
      require("packer").install()
      -- TODO: add a changelog
      vim.notify("Update complete", vim.log.levels.INFO)
      vim.cmd "LspStart"
    end)
  end
end

return M
