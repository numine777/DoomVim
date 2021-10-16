local M = {}

package.loaded["dvim.utils.hooks"] = nil
local _, hooks = pcall(require, "dvim.utils.hooks")

---Join path segments that were passed as input
---@return string
function _G.join_paths(...)
  local uv = vim.loop
  local path_sep = uv.os_uname().version:match "Windows" and "\\" or "/"
  local result = table.concat({ ... }, path_sep)
  return result
end

---Get the full path to `$DOOMVIM_RUNTIME_DIR`
---@return string
function _G.get_runtime_dir()
  local dvim_runtime_dir = os.getenv "DOOMVIM_RUNTIME_DIR"
  if not dvim_runtime_dir then
    -- when nvim is used directly
    return vim.fn.stdpath "config"
  end
  return dvim_runtime_dir
end

---Get the full path to `$DOOMVIM_CONFIG_DIR`
---@return string
function _G.get_config_dir()
  local dvim_config_dir = os.getenv "DOOMVIM_CONFIG_DIR"
  if not dvim_config_dir then
    return vim.fn.stdpath "config"
  end
  return dvim_config_dir
end

---Get the full path to `$DOOMVIM_CACHE_DIR`
---@return string
function _G.get_cache_dir()
  local dvim_cache_dir = os.getenv "DOOMVIM_CACHE_DIR"
  if not dvim_cache_dir then
    return vim.fn.stdpath "cache"
  end
  return dvim_cache_dir
end

---Get the full path to the currently installed doomvim repo
---@return string
local function get_install_path()
  local dvim_runtime_dir = os.getenv "DOOMVIM_RUNTIME_DIR"
  if not dvim_runtime_dir then
    -- when nvim is used directly
    return vim.fn.stdpath "config"
  end
  return join_paths(dvim_runtime_dir, "dvim")
end

---Get currently installed version of DoomVim
---@param type string can be "short"
---@return string
function _G.get_version(type)
  type = type or ""
  local dvim_full_ver = vim.fn.system("git -C " .. get_install_path() .. " describe --tags")

  if string.match(dvim_full_ver, "%d") == nil then
    return nil
  end
  if type == "short" then
    return vim.fn.split(dvim_full_ver, "-")[1]
  else
    return string.sub(dvim_full_ver, 1, #dvim_full_ver - 1)
  end
end

---Initialize the `&runtimepath` variables and prepare for startup
---@return table
function M:init()
  self.runtime_dir = get_runtime_dir()
  self.config_dir = get_config_dir()
  self.cache_path = get_cache_dir()
  self.install_path = get_install_path()

  self.pack_dir = join_paths(self.runtime_dir, "site", "pack")
  self.packer_install_dir = join_paths(self.runtime_dir, "site", "pack", "packer", "start", "packer.nvim")
  self.packer_cache_path = join_paths(self.config_dir, "plugin", "packer_compiled.lua")

  if os.getenv "DOOMVIM_RUNTIME_DIR" then
    vim.opt.rtp:remove(join_paths(vim.fn.stdpath "data", "site"))
    vim.opt.rtp:remove(join_paths(vim.fn.stdpath "data", "site", "after"))
    vim.opt.rtp:prepend(join_paths(self.runtime_dir, "site"))
    vim.opt.rtp:append(join_paths(self.runtime_dir, "site", "after"))

    vim.opt.rtp:remove(vim.fn.stdpath "config")
    vim.opt.rtp:remove(join_paths(vim.fn.stdpath "config", "after"))
    vim.opt.rtp:prepend(self.config_dir)
    vim.opt.rtp:append(join_paths(self.config_dir, "after"))
    -- TODO: we need something like this: vim.opt.packpath = vim.opt.rtp

    vim.cmd [[let &packpath = &runtimepath]]
    vim.cmd("set spellfile=" .. join_paths(self.config_dir, "spell", "en.utf-8.add"))
  end

  vim.fn.mkdir(get_cache_dir(), "p")

  -- FIXME: currently unreliable in unit-tests
  if not os.getenv "dvim_TEST_ENV" then
    require("dvim.impatient").setup {
      path = vim.fn.stdpath "cache" .. "/dvim_cache",
      enable_profiling = true,
    }
  end

  require("dvim.config"):init()

  require("dvim.plugin-loader"):init {
    package_root = self.pack_dir,
    install_path = self.packer_install_dir,
  }

  return self
end

---Update DoomVim
---pulls the latest changes from github and, resets the startup cache
function M:update()
  hooks.run_pre_update()
  M:update_repo()
  hooks.run_post_update()
end

local function git_cmd(subcmd)
  local Job = require "plenary.job"
  local Log = require "dvim.core.log"
  local args = { "-C", get_install_path() }
  vim.list_extend(args, subcmd)

  local stderr = {}
  local stdout, ret = Job
    :new({
      command = "git",
      args = args,
      cwd = get_install_path(),
      on_stderr = function(_, data)
        table.insert(stderr, data)
      end,
    })
    :sync()

  if not vim.tbl_isempty(stderr) then
    Log:debug(stderr)
  end

  if not vim.tbl_isempty(stdout) then
    Log:debug(stdout)
  end

  return ret
end

---pulls the latest changes from github
function M:update_repo()
  local Log = require "dvim.core.log"
  local sub_commands = {
    fetch = { "fetch" },
    diff = { "diff", "--quiet", "@{upstream}" },
    merge = { "merge", "--ff-only", "--progress" },
  }
  Log:info "Checking for updates"

  local ret = git_cmd(sub_commands.fetch)
  if ret ~= 0 then
    Log:error "Update failed! Check the log for further information"
    return
  end

  ret = git_cmd(sub_commands.diff)

  if ret == 0 then
    Log:info "DoomVim is already up-to-date"
    return
  end

  ret = git_cmd(sub_commands.merge)

  if ret ~= 0 then
    Log:error "Update failed! Please pull the changes manually instead."
    return
  end
end

return M
