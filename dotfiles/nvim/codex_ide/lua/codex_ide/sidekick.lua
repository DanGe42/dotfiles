local M = {}

function M.setup()
  if M.configured then return end
  M.configured = true
  local ide_sent = false
  vim.api.nvim_create_autocmd("TermClose", {
    callback = function(args)
      if vim.b[args.buf].sidekick_cli == "codex" then ide_sent = false end
    end,
  })
  local function open_codex(with_visual_context)
    local ide = require("codex_ide")
    if with_visual_context then ide.capture_visual() end
    local ok, err = ide.open()
    if not ok then
      require("sidekick.cli").show({ name = "codex", focus = true })
      vim.notify("Codex IDE IPC unavailable (" .. (ide.status().path or "unknown socket") .. "): " .. tostring(err), vim.log.levels.ERROR)
      return
    end
    -- Resolve exactly one Sidekick session before writing /ide on.
    require("sidekick.cli.state").with(function(state)
      if not ide_sent then
        state.session:send("/ide on\n")
        ide_sent = true
      end
    end, { attach = true, filter = { name = "codex" }, focus = true, show = true })
  end
  vim.keymap.set("n", "<leader>zc", function() open_codex(false) end, { desc = "Open Codex with IDE context" })
  vim.keymap.set("x", "<leader>zc", function() open_codex(true) end, { desc = "Open Codex with IDE context" })
  vim.keymap.set("x", "<leader>xx", function()
    require("codex_ide").capture_visual()
    require("sidekick.cli").show({ name = "codex", focus = true })
  end, { desc = "Focus Codex from selection" })
end

-- This is deliberately only the Codex-specific portion of Sidekick's options.
-- Keep general Sidekick UI and feature preferences in plugins.lua.
function M.codex_tool_options()
  local ide = require("codex_ide")
  return {
    env = { CODEX_HOME = ide.home() },
    is_proc = function(_, proc)
      return proc.cmd:match("%f[%w]codex%f[%W]") ~= nil
        and proc.env and proc.env.CODEX_HOME == ide.home()
    end,
  }
end

return M
