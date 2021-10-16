local M = {}

function M.config()
  -- Define this minimal config so that it's available if telescope is not yet available.
  dvim.builtin.telescope = {
    ---@usage disable telescope completely [not recommeded]
    active = true,
    on_config_done = nil,
  }

  dvim.builtin.telescope = vim.tbl_extend("force", dvim.builtin.telescope, {
    defaults = {
      prompt_prefix = " ",
      selection_caret = " ",
      entry_prefix = "  ",
      initial_mode = "insert",
      selection_strategy = "reset",
      sorting_strategy = "descending",
      layout_strategy = "horizontal",
      layout_config = {
        width = 0.75,
        preview_cutoff = 120,
        horizontal = { mirror = false },
        vertical = { mirror = false },
      },
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden",
      },
      file_ignore_patterns = {},
      path_display = { shorten = 5 },
      winblend = 0,
      border = {},
      borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      color_devicons = true,
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
      pickers = {
        find_files = {
          find_command = { "fd", "--type=file", "--hidden", "--smart-case" },
        },
        live_grep = {
          --@usage don't include the filename in the search results
          only_sort_text = true,
        },
      },
    },
    extensions = {
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      },
    },
  })
end

function M.code_actions()
  local opts = {
    winblend = 15,
    layout_config = {
      prompt_position = "top",
      width = 80,
      height = 12,
    },
    borderchars = {
      prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
      results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
      preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    },
    border = {},
    previewer = false,
    shorten_path = false,
  }
  local builtin = require "telescope.builtin"
  local themes = require "telescope.themes"
  builtin.lsp_code_actions(themes.get_dropdown(opts))
end

function M.setup()
  local previewers = require "telescope.previewers"
  local sorters = require "telescope.sorters"
  local actions = require "telescope.actions"

  dvim.builtin.telescope = vim.tbl_extend("keep", {
    file_previewer = previewers.vim_buffer_cat.new,
    grep_previewer = previewers.vim_buffer_vimgrep.new,
    qflist_previewer = previewers.vim_buffer_qflist.new,
    file_sorter = sorters.get_fuzzy_file,
    generic_sorter = sorters.get_generic_fuzzy_sorter,
    ---@usage Mappings are fully customizable. Many familiar mapping patterns are setup as defaults.
    mappings = {
      i = {
        ["<C-n>"] = actions.move_selection_next,
        ["<C-p>"] = actions.move_selection_previous,
        ["<C-c>"] = actions.close,
        ["<C-j>"] = actions.cycle_history_next,
        ["<C-k>"] = actions.cycle_history_prev,
        ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
        ["<CR>"] = actions.select_default + actions.center,
      },
      n = {
        ["<C-n>"] = actions.move_selection_next,
        ["<C-p>"] = actions.move_selection_previous,
        ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
      },
    },
  }, dvim.builtin.telescope)

  local telescope = require "telescope"
  telescope.setup(dvim.builtin.telescope)

  if dvim.builtin.project.active then
    pcall(function()
      require("telescope").load_extension "projects"
    end)
  end

  dvim.keys.normal_mode["<leader>rr"] = ':lua require("lv-telescope").refactors()<CR>'
  dvim.keys.visual_mode["<leader>rr"] = ':lua require("lv-telescope").refactors()<CR>'
  dvim.keys.visual_block_mode["<leader>rr"] = ':lua require("lv-telescope").refactors()<CR>'
  dvim.keys.normal_mode["<leader>ps"] = ':lua require("telescope.builtin").grep_string({ search = vim.fn.input("Grep For > ")})<CR>'
  dvim.keys.normal_mode["<C-p>"] = ':lua require("telescope.builtin").git_files()<CR>'
  dvim.keys.normal_mode["<leader>pf"] = ':lua require("telescope.builtin").find_files()<CR>'
  dvim.keys.normal_mode["<leader>vh"] = ':lua require("telescope.builtin").help_tags()<CR>'
  dvim.keys.normal_mode["<leader>vm"] = ':Telescope man_pages<CR>'
  dvim.keys.normal_mode["<leader>vk"] = ':Telescope keymaps<CR>'
  dvim.keys.normal_mode["<leader>vc"] = ':Telescope colorscheme<CR>'
  dvim.keys.normal_mode["<leader>vC"] = ':Telescope commands<CR>'
  dvim.keys.normal_mode["<leader>vr"] = ':Telescope registers<CR>'
  dvim.keys.normal_mode["<leader>gw"] = ':lua require("telescope").extensions.git_worktree.git_worktrees()<CR>'
  dvim.keys.normal_mode["<leader>gw"] = ':lua require("telescope").extensions.git_worktree.create_git_worktree()<CR>'

  if dvim.builtin.telescope.on_config_done then
    dvim.builtin.telescope.on_config_done(telescope)
  end

  if dvim.builtin.telescope.extensions and dvim.builtin.telescope.extensions.fzf then
    require("telescope").load_extension "fzf"
  end

  if dvim.builtin.telescope.extensions and dvim.builtin.telescope.extensions.git_worktree then
    require("telescope").load_extension "git_worktree"
  end

  if dvim.builtin.telescope.extensions and dvim.builtin.telescope.extensions.flutter then
    require("telescope").load_extension "flutter"
  end
end

local function refactor(prompt_bufnr)
	local content = require("telescope.actions.state").get_selected_entry(prompt_bufnr)
	require("telescope.actions").close(prompt_bufnr)
	require("refactoring").refactor(content.value)
end

M.refactors = function()
	require("telescope.pickers").new({}, {
		prompt_title = "refactors",
		finder = require("telescope.finders").new_table({
			results = require("refactoring").get_refactors(),
		}),
		sorter = require("telescope.config").values.generic_sorter({}),
		attach_mappings = function(_, map)
			map("i", "<CR>", refactor)
			map("n", "<CR>", refactor)
			return true
		end,
	}):find()
end

return M
