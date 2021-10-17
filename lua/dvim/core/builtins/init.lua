local M = {}

local builtins = {
  "dvim.keymappings",
  -- "dvim.core.which-key",
  "dvim.core.gitsigns",
  "dvim.core.cmp",
  "dvim.core.dashboard",
  "dvim.core.dap",
  "dvim.core.terminal",
  "dvim.core.telescope",
  "dvim.core.treesitter",
  "dvim.core.nvimtree",
  "dvim.core.project",
  -- "dvim.core.bufferline",
  "dvim.core.autopairs",
  "dvim.core.comment",
  "dvim.core.lualine",
}

function M.config(config)
  for _, builtin_path in ipairs(builtins) do
    local builtin = require(builtin_path)
    builtin.config(config)
  end
end

return M
