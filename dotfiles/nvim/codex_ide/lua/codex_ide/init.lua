local M = {}
local context, server = require("codex_ide.context"), require("codex_ide.server")
local home = require("codex_ide.home")
local configured = false
local function setup()
  if configured then return end
  configured = true; context.setup(); context.note_focus()
  vim.api.nvim_create_user_command("CodexIdeStart", function()
    local ok, err = server.start(); vim.notify(ok and "Codex IDE IPC started" or ("Codex IDE IPC: " .. err), ok and vim.log.levels.INFO or vim.log.levels.ERROR)
  end, {})
  vim.api.nvim_create_user_command("CodexIdeStop", function() server.stop() end, {})
  vim.api.nvim_create_user_command("CodexIdeStatus", function()
    local s = server.status(); vim.notify(s.running and ("Codex IDE IPC: " .. s.path) or "Codex IDE IPC is stopped")
  end, {})
  vim.api.nvim_create_autocmd("VimLeavePre", { callback = server.stop })
end
function M.start() setup(); return server.start() end
function M.setup() setup() end
function M.stop() return server.stop() end
function M.status() return server.status() end
function M.home() return home.get() end
function M.capture_visual() setup(); return context.capture_visual() end
function M.open()
  setup()
  local ok, err = server.start()
  return ok, err
end
return M
