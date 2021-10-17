local M = {}

M.defaults = {
  [[
  function! QuickFixToggle()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen
    else
      cclose
    endif
  endfunction
  ]],
  -- :DvimInfo
  [[ command! DvimInfo lua require('dvim.core.info').toggle_popup(vim.bo.filetype) ]],
  [[ command! DvimCacheReset lua require('dvim.utils.hooks').reset_cache() ]],
  [[ command! DvimUpdate lua require('dvim.bootstrap').update() ]],
}

M.load = function(commands)
  for _, command in ipairs(commands) do
    vim.cmd(command)
  end
end

return M
