-- LSP Configuration for Neovim 0.11+ (minimal with Mason)

-- Mason setup (installs and manages LSP servers)
require("mason").setup()

-- Auto-install these LSP servers via Mason package names.
local mason_packages = {
  "lua-language-server",
  "pyright",
  "gopls",
  "jdtls",
  "ruby-lsp",
}

local mason_registry = require("mason-registry")
for _, package_name in ipairs(mason_packages) do
  local ok, package = pcall(mason_registry.get_package, package_name)
  if ok and not package:is_installed() then
    package:install()
  end
end

-- Keybindings when LSP attaches
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gl', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

    if client and client.name == 'ruby_lsp' then
      vim.keymap.set('n', '<leader>cf', vim.lsp.buf.format, opts)
    end
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
vim.lsp.config('jdtls', {
  capabilities = capabilities,
  root_markers = {
    ".git",
    "mvnw",
    "gradlew",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
  },
})
vim.lsp.config('ruby_lsp', {
  capabilities = capabilities,
  cmd = { 'ruby-lsp' },
  root_markers = {
    'Gemfile',
    '.ruby-version',
    '.git',
  },
})

-- Enable the servers
vim.lsp.enable({ 'lua_ls', 'pyright', 'gopls', 'jdtls', 'ruby_lsp' })
