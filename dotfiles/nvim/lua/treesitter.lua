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
