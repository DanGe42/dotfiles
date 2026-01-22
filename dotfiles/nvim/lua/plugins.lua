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
  -- LSP Support (using native Neovim 0.11+ LSP)
  -- =========================================================================
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
  },

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
    },
    config = function()
      require('completion')  -- Setup completion first
      require('lsp')         -- Then setup LSP (which uses cmp capabilities)
    end,
  },

  -- =========================================================================
  -- Treesitter (optional - better syntax highlighting)
  -- =========================================================================
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   build = ":TSUpdate",
  -- },

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

  -- Language-specific
  { "vim-latex/vim-latex" },
  { "gregsexton/MatchTag" },
})
