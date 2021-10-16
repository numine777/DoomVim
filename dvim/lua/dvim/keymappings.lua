local M = {}
local Log = require "dvim.core.log"

local generic_opts_any = { noremap = true, silent = true }

local generic_opts = {
  insert_mode = generic_opts_any,
  normal_mode = generic_opts_any,
  visual_mode = generic_opts_any,
  visual_block_mode = generic_opts_any,
  command_mode = generic_opts_any,
  term_mode = { silent = true },
}

local mode_adapters = {
  insert_mode = "i",
  normal_mode = "n",
  term_mode = "t",
  visual_mode = "v",
  visual_block_mode = "x",
  command_mode = "c",
}

-- Append key mappings to lunarvim's defaults for a given mode
-- @param keymaps The table of key mappings containing a list per mode (normal_mode, insert_mode, ..)
function M.append_to_defaults(keymaps)
  for mode, mappings in pairs(keymaps) do
    for k, v in ipairs(mappings) do
      dvim.keys[mode][k] = v
    end
  end
end

-- Set key mappings individually
-- @param mode The keymap mode, can be one of the keys of mode_adapters
-- @param key The key of keymap
-- @param val Can be form as a mapping or tuple of mapping and user defined opt
function M.set_keymaps(mode, key, val)
  local opt = generic_opts[mode] and generic_opts[mode] or generic_opts_any
  if type(val) == "table" then
    opt = val[2]
    val = val[1]
  end
  vim.api.nvim_set_keymap(mode, key, val, opt)
end

-- Load key mappings for a given mode
-- @param mode The keymap mode, can be one of the keys of mode_adapters
-- @param keymaps The list of key mappings
function M.load_mode(mode, keymaps)
  mode = mode_adapters[mode] and mode_adapters[mode] or mode
  for k, v in pairs(keymaps) do
    M.set_keymaps(mode, k, v)
  end
end

-- Load key mappings for all provided modes
-- @param keymaps A list of key mappings for each mode
function M.load(keymaps)
  for mode, mapping in pairs(keymaps) do
    M.load_mode(mode, mapping)
  end
end

function M.config()
  dvim.keys = {
    ---@usage change or add keymappings for insert mode
    insert_mode = {
      -- 'jk' for quitting insert mode
      ["jk"] = "<ESC>",
      -- 'kj' for quitting insert mode
      ["kj"] = "<ESC>",
      -- 'jj' for quitting insert mode
      ["jj"] = "<ESC>",
      -- Where is your god now?
      ["<C-c>"] = "<ESC>",
      -- navigate tab completion with <c-j> and <c-k>
      -- runs conditionally
      ["<C-j>"] = { 'pumvisible() ? "\\<down>" : "\\<C-j>"', { expr = true, noremap = true } },
      ["<C-k>"] = { 'pumvisible() ? "\\<up>" : "\\<C-k>"', { expr = true, noremap = true } },
    },

    ---@usage change or add keymappings for normal mode
    normal_mode = {
      -- Resize with arrows
      ["<C-Up>"] = ":resize -2<CR>",
      ["<C-Down>"] = ":resize +2<CR>",
      ["<C-Left>"] = ":vertical resize -2<CR>",
      ["<C-Right>"] = ":vertical resize +2<CR>",

      -- Tab switch buffer
      ["<S-l>"] = ":BufferNext<CR>",
      ["<S-h>"] = ":BufferPrevious<CR>",

      -- QuickFix
      ["<C-k>"] = ":cnext<CR>zz",
      ["<C-j>"] = ":cprev<CR>zz",
      ["<leader>k"] = ":lnext<CR>zz",
      ["<leader>j"] = ":lprev<CR>zz",
      ["<C-q>"] = ":call QuickFixToggle()<CR>",

      -- Cut and paste improvements
      ["<leader>y"] = '"+y',
      ["<leader>Y"] = 'gg"+y',
      ["<leader>d"] = '"_d',

      -- Find and replace
      ["<leader>s"] = ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>",

      -- Netrw
      ["<leader>pv"] = ":Ex<CR>",

      -- NvimTreeToggle
      ["<leader>e"] = ":NvimTreeToggle<CR>",

      -- Scratch
      ["<leader>gs"] = ":Scratch<CR>",

      -- UndoTree
      ["<leader>u"] = ":UndotreeShow",
    },

    ---@usage change or add keymappings for terminal mode
    term_mode = {
      -- Terminal window navigation
      ["<Esc>"] = "<C-\\><C-n>",
    },

    ---@usage change or add keymappings for visual mode
    visual_mode = {
      -- Better indenting
      ["<"] = "<gv",
      [">"] = ">gv",

      -- Cut and paste improvements
      ["<leader>y"] = '"+y',
      ["<leader>p"] = '"_dP',
      ["<leader>d"] = '"_d',
      -- ["p"] = '"0p',
      -- ["P"] = '"0P',
    },

    ---@usage change or add keymappings for visual block mode
    visual_block_mode = {
      -- Move selected line / block of text in visual mode
      ["K"] = ":move '<-2<CR>gv-gv",
      ["J"] = ":move '>+1<CR>gv-gv",
    },

    ---@usage change or add keymappings for command mode
    command_mode = {
      -- navigate tab completion with <c-j> and <c-k>
      -- runs conditionally
      ["<C-j>"] = { 'pumvisible() ? "\\<C-n>" : "\\<C-j>"', { expr = true, noremap = true } },
      ["<C-k>"] = { 'pumvisible() ? "\\<C-p>" : "\\<C-k>"', { expr = true, noremap = true } },
    },
  }

  if vim.fn.has "mac" == 1 then
    dvim.keys.normal_mode["<A-Up>"] = dvim.keys.normal_mode["<C-Up>"]
    dvim.keys.normal_mode["<A-Down>"] = dvim.keys.normal_mode["<C-Down>"]
    dvim.keys.normal_mode["<A-Left>"] = dvim.keys.normal_mode["<C-Left>"]
    dvim.keys.normal_mode["<A-Right>"] = dvim.keys.normal_mode["<C-Right>"]
    Log:debug "Activated mac keymappings"
  end
end

function M.print(mode)
  print "List of DoomVim's default keymappings"
  if mode then
    print(vim.inspect(dvim.keys[mode]))
  else
    print(vim.inspect(dvim.keys))
  end
end

function M.setup()
  vim.g.mapleader = (dvim.leader == "space" and " ") or dvim.leader
  M.load(dvim.keys)
end

return M
