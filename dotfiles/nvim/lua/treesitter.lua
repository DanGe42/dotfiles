-- Treesitter configuration (using current API)

-- Desired parsers - install missing ones only
local desired_parsers = {
  "c", "lua", "python", "go", "javascript", "html", "css",
  "bash", "json", "yaml", "markdown", "hcl", "terraform", "latex", "java",
  "ruby", "embedded_template", "sql",
}

local missing = {}
for _, lang in ipairs(desired_parsers) do
  local ok = pcall(vim.treesitter.language.inspect, lang)
  if not ok then
    table.insert(missing, lang)
  end
end

if #missing > 0 then
  require("nvim-treesitter").install(missing)
end

-- Neovim's default colors render Constant and Type like normal text. Ruby's
-- constants and class/module names are already captured, so give those Ruby-
-- specific captures the colorscheme's Identifier color instead.
local function set_ruby_highlights()
  for _, group in ipairs({
    "@constant.ruby",
    "@type.ruby",
    "@lsp.type.class.ruby",
    "@lsp.type.namespace.ruby",
  }) do
    vim.api.nvim_set_hl(0, group, { link = "Identifier" })
  end
end

set_ruby_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_ruby_highlights,
})

-- Enable Treesitter highlighting and indentation for all file types
-- Ruby/ERB use Neovim's built-in indenter: treesitter indent for Ruby is buggy.
local ts_indent_exclude = { ruby = true, eruby = true }
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    if pcall(vim.treesitter.start) then
      if not ts_indent_exclude[vim.bo.filetype] then
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end
  end,
})
