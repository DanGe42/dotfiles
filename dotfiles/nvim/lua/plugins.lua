-- Plugin management with lazy.nvim
-- Bootstrap lazy.nvim (auto-install if not present)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
require("lazy").setup({
  -- =========================================================================
  -- Colorscheme
  -- =========================================================================
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      palette = "solarized",
      variant = "autumn",
      on_highlights = function(colors)
        local highlights = {
          SolarizedWinterKeyword = { fg = colors.base01, bold = true },
        }

        for _, capture in ipairs({
          "@keyword.ruby",
          "@keyword.conditional.ruby",
          "@keyword.directive.ruby",
          "@keyword.exception.ruby",
          "@keyword.function.ruby",
          "@keyword.import.ruby",
          "@keyword.modifier.ruby",
          "@keyword.operator.ruby",
          "@keyword.repeat.ruby",
          "@keyword.return.ruby",
          "@keyword.type.ruby",
        }) do
          highlights[capture] = { link = "SolarizedWinterKeyword" }
        end

        return highlights
      end,
    },
    config = function(_, opts)
      vim.opt.termguicolors = true
      vim.opt.background = "light"
      require("solarized").setup(opts)
      vim.cmd.colorscheme("solarized")
    end,
  },

  -- =========================================================================
  -- LSP Support (using native Neovim 0.11+ LSP)
  -- =========================================================================
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
  },
  { "neovim/nvim-lspconfig" },

  -- =========================================================================
  -- Completion
  -- =========================================================================
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",    -- LSP completion source
      "hrsh7th/cmp-buffer",      -- Buffer text completion
      "hrsh7th/cmp-path",        -- Path completion
      "L3MON4D3/LuaSnip",        -- Snippet engine
      "saadparwaiz1/cmp_luasnip", -- LuaSnip completion source
      "williamboman/mason.nvim", -- LSP needs mason too
      "neovim/nvim-lspconfig",   -- Server definitions for vim.lsp
    },
    config = function()
      require('completion')  -- Setup completion first
      require('lsp')         -- Then setup LSP (which uses cmp capabilities)
    end,
  },

  -- =========================================================================
  -- Treesitter (optional - better syntax highlighting)
  -- =========================================================================
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require('treesitter')
    end,
  },

  -- =========================================================================
  -- Traditional plugins (VimScript-based, work in Vim and Neovim)
  -- =========================================================================

  -- Git integration
  { "tpope/vim-fugitive" },
  { "tpope/vim-endwise" },

  -- Fuzzy finder
  {
    "junegunn/fzf",
    build = "./install --all",
  },
  { "junegunn/fzf.vim" },

  -- UI
  { "vim-airline/vim-airline" },
  { "bronson/vim-trailing-whitespace" },

  -- Utility
  { "mbbill/undotree" },
  { "junegunn/vim-easy-align" },
  { "vim-test/vim-test" },

  -- Language-specific
  { "vim-latex/vim-latex" },
  { "gregsexton/MatchTag" },

  -- =========================================================================
  -- AI
  -- =========================================================================
  {
    "coder/claudecode.nvim",
    cmd = { "ClaudeCode", "ClaudeCodeOpen", "ClaudeCodeClose", "ClaudeCodeSend" },
    opts = {},
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>",     desc = "Toggle Claude" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd<cr>",  desc = "Add buffer to Claude" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", desc = "Send selection to Claude", mode = "v" },
    },
  },
  {
    "folke/sidekick.nvim",
    opts = {
      nes = {
        enabled = false,
      },
      copilot = {
        status = {
          enabled = false,
        },
      },
      cli = {
        watch = false,
        mux = {
          enabled = false,
        },
        win = {
          layout = "right",
          split = {
            width = 80,
          },
        },
      },
    },
    keys = {
      {
        "<leader>xc",
        function()
          require("sidekick.cli").toggle({
            name = "codex",
            focus = true,
          })
        end,
        desc = "Toggle Codex",
      },
      {
        "<leader>xx",
        function()
          require("sidekick.cli").show({
            name = "codex",
            focus = true,
          })
        end,
        desc = "Focus Codex",
      },
      {
        "<leader>xs",
        function()
          require("sidekick.cli").send({
            name = "codex",
            msg = "{position}\n{selection}",
            focus = false,
          })
        end,
        desc = "Send selection to Codex",
        mode = "x",
      },
    },
  },
})
