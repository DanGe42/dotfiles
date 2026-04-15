-- Completion configuration (minimal setup)

local cmp = require("cmp")

-- REQUIRED: Basic setup
cmp.setup({
  -- Disable completion in filetypes where popup suggestions are noisy
  enabled = function()
    local filetype = vim.bo.filetype
    if filetype == 'gitcommit' or filetype == 'markdown' then return false end
    return true
  end,

  -- REQUIRED: Snippet engine
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },

  -- REQUIRED: Keybindings for completion menu
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp.mapping.select_next_item(),      -- Tab to next item
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),    -- Shift-Tab to previous
    ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Enter only confirms an explicit selection
    ['<C-Space>'] = cmp.mapping.complete(),          -- Ctrl-Space to trigger
    ['<C-e>'] = cmp.mapping.abort(),                 -- Ctrl-e to close
  }),

  -- REQUIRED: Sources (where completions come from)
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },  -- From LSP
    { name = 'buffer' },    -- From current buffer
    { name = 'path' },      -- File paths
  })
})
