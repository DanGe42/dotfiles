-- LSP Configuration for Neovim 0.11+ (minimal with Mason)

-- Mason setup (installs and manages LSP servers)
require("mason").setup()

-- Auto-install these LSP servers
local servers = { "lua_ls", "pyright", "gopls" }

local mason_registry = require("mason-registry")
for _, server_name in ipairs(servers) do
  local ok, server = pcall(mason_registry.get_package, server_name)
  if ok and not server:is_installed() then
    server:install()
  end
end

-- Keybindings when LSP attaches
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
  end,
})

-- Enable nvim-cmp integration (loaded after cmp plugin is available)
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Configure LSP servers
vim.lsp.config('lua_ls', {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } }
    }
  }
})

vim.lsp.config('pyright', { capabilities = capabilities })
vim.lsp.config('gopls', { capabilities = capabilities })

-- Enable the servers
vim.lsp.enable({ 'lua_ls', 'pyright', 'gopls' })
