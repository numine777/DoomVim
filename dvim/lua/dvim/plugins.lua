return {
	-- Packer can manage itself as an optional plugin
	{ "wbthomason/packer.nvim" },
	{ "neovim/nvim-lspconfig" },
	{ "tamago324/nlsp-settings.nvim" },
	{ "jose-elias-alvarez/null-ls.nvim" },
	{ "antoinemadec/FixCursorHold.nvim" }, -- Needed while issue https://github.com/neovim/neovim/issues/12587 is still open
	{
		"williamboman/nvim-lsp-installer",
	},

	{ "nvim-lua/popup.nvim" },
	{ "nvim-lua/plenary.nvim" },
	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		config = function()
			require("dvim.core.telescope").setup()
		end,
		disable = not dvim.builtin.telescope.active,
	},
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    run = "make",
    disable = not lvim.builtin.telescope.active,
  },
	-- Install nvim-cmp, and buffer source as a dependency
	{
		"hrsh7th/nvim-cmp",
		config = function()
			require("dvim.core.cmp").setup()
		end,
		requires = {
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lua",
		},
		run = function()
			-- cmp's config requires cmp to be installed to run the first time
			if not dvim.builtin.cmp then
				require("dvim.core.cmp").config()
			end
		end,
	},
	{
		"rafamadriz/friendly-snippets",
		-- event = "InsertCharPre",
		-- disable = not dvim.builtin.compe.active,
	},

	-- Autopairs
	{
		"windwp/nvim-autopairs",
		-- event = "InsertEnter",
		config = function()
			require("dvim.core.autopairs").setup()
		end,
		disable = not dvim.builtin.autopairs.active,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "0.5-compat",
		-- run = ":TSUpdate",
		config = function()
			require("dvim.core.treesitter").setup()
		end,
	},

	-- NvimTree
	{
		"kyazdani42/nvim-tree.lua",
		-- event = "BufWinOpen",
		-- cmd = "NvimTreeToggle",
		-- commit = "fd7f60e242205ea9efc9649101c81a07d5f458bb",
		config = function()
			require("dvim.core.nvimtree").setup()
		end,
		disable = not dvim.builtin.nvimtree.active,
	},

	{
		"lewis6991/gitsigns.nvim",

		config = function()
			require("dvim.core.gitsigns").setup()
		end,
		event = "BufRead",
		disable = not dvim.builtin.gitsigns.active,
	},

	-- Comments
	{
		"numToStr/Comment.nvim",
		event = "BufRead",
		config = function()
			require("dvim.core.comment").setup()
		end,
		disable = not dvim.builtin.comment.active,
	},

	-- project.nvim
	{
		"ahmedkhalf/project.nvim",
		config = function()
			require("dvim.core.project").setup()
		end,
		disable = not dvim.builtin.project.active,
	},

	-- Icons
	{ "kyazdani42/nvim-web-devicons" },

	-- Status Line and Bufferline
	{
		-- "hoob3rt/lualine.nvim",
		"shadmansaleh/lualine.nvim",
		-- "Lunarvim/lualine.nvim",
		config = function()
			require("dvim.core.lualine").setup()
		end,
		disable = not dvim.builtin.lualine.active,
	},

	-- {
	--   "romgrk/barbar.nvim",
	--   config = function()
	--     require("dvim.core.bufferline").setup()
	--   end,
	--   event = "BufWinEnter",
	--   disable = not dvim.builtin.bufferline.active,
	-- },

	-- Debugging
	{
		"mfussenegger/nvim-dap",
		-- event = "BufWinEnter",
		config = function()
			require("dvim.core.dap").setup()
		end,
		-- disable = not dvim.builtin.dap.active,
	},

	-- Debugger management
	{
		"Pocco81/DAPInstall.nvim",
		-- event = "BufWinEnter",
		-- event = "BufRead",
		-- disable = not dvim.builtin.dap.active,
	},

	-- Dashboard
	{
		"ChristianChiarulli/dashboard-nvim",
		event = "BufWinEnter",
		config = function()
			require("dvim.core.dashboard").setup()
		end,
		disable = not dvim.builtin.dashboard.active,
	},

	-- Terminal
	{
		"akinsho/toggleterm.nvim",
		event = "BufWinEnter",
		config = function()
			require("dvim.core.terminal").setup()
		end,
		disable = not dvim.builtin.terminal.active,
	},

	{
		"akinsho/flutter-tools.nvim",
	},

	{
		"ThePrimeagen/git-worktree.nvim",
	},

	{
		"tpope/vim-fugitive",
	},

	{
		"ThePrimeagen/harpoon",
	},

	{
		"mtth/scratch.vim",
	},

	{
		"npxbr/gruvbox.nvim",
		requires = { "rktjmp/lush.nvim" },
	},
}
