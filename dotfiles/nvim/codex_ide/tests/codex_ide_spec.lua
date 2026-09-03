-- Run from dotfiles/nvim: nvim --headless -u NONE -i NONE -l codex_ide/tests/codex_ide_spec.lua
vim.opt.rtp:prepend(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h"))
local framing = require("codex_ide.framing")
local server = require("codex_ide.server")
local context = require("codex_ide.context")
context.setup()
local function eq(a, b) assert(vim.deep_equal(a, b), vim.inspect(a) .. " ~= " .. vim.inspect(b)) end

local frames = {}
local decoder = framing.decoder(function(v) table.insert(frames, v) end, error)
local one, two = assert(framing.encode({ requestId = "one" })), assert(framing.encode({ requestId = "two" }))
decoder(one:sub(1, 2)); decoder(one:sub(3) .. two)
eq(frames, { { requestId = "one" }, { requestId = "two" } })
local failed = false
framing.decoder(function() end, function() failed = true end)(string.char(1, 0, 0, 16))
assert(failed, "oversized frame was accepted")

local reply = server.response({ type = "request", method = "ide-context", version = 1, requestId = "keep-me" })
eq(reply, { type = "response", requestId = "keep-me", resultType = "error", error = "request-version-mismatch" })
assert(server.response({ type = "request", method = "other", version = 0 }).error == "no-handler-for-request")

vim.cmd("enew!")
vim.bo.buflisted = true
vim.api.nvim_buf_set_name(0, "/repo/a😀.lua")
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "a😀bc", "second" })
context.note_focus()
context.clear_selection()
vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("ggV", true, false, true), "xt", false)
assert(vim.wait(500, function() return context.selection and context.selection.text == "a😀bc" end, 10), "visual-mode entry capture timed out")
vim.api.nvim_feedkeys("j", "xt", false)
context.capture_visual()
vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "xt", false)
assert(vim.wait(500, function() return context.selection and context.selection.text == "a😀bc\nsecond" end, 10), "linewise selection capture timed out")
eq(context.selection.finish, { line = 2, character = 0 })
local snap = context.snapshot("/repo")
eq(snap.activeFile.path, "a😀.lua")
eq(snap.activeFile.selection.start, { line = 0, character = 0 })
assert(#snap.openTabs == 1)
vim.keymap.set("x", "\\zc", function()
  if vim.fn.mode():match("^[vV\22]") then context.capture_visual() end
end, { buffer = 0 })
vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gg0v3l\\zc", true, false, true), "xt", false)
assert(vim.wait(500, function() return context.selection ~= nil end, 10), "visual capture timed out")
eq(context.selection.text, "a😀bc")
eq(context.selection.start, { line = 0, character = 0 })
eq(context.selection.finish, { line = 0, character = 5 })
vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("ggVj\\zc", true, false, true), "xt", false)
assert(vim.wait(500, function() return context.selection and context.selection.text == "a😀bc\nsecond" end, 10), "linewise visual capture timed out")
eq(context.selection.start, { line = 0, character = 0 })
eq(context.selection.finish, { line = 2, character = 0 })
eq(context.selection.ranges, {})
local success = server.response({ type = "request", method = "ide-context", version = 0, requestId = "ok", params = { workspaceRoot = "/repo" } })
eq(success.requestId, "ok")
eq(success.handledByClientId, "neovim-codex-ide")
eq(success.result.type, "broadcast")

-- This reaches the real libuv listener when explicitly enabled. It is opt-in
-- because sandboxed CI environments often prohibit AF_UNIX bind().
if vim.env.CODEX_IDE_SOCKET_TEST == "1" then
  local path = vim.fn.tempname() .. "/ipc.sock"
  local ok, err = server.start({ path = path })
  assert(ok, err)
  local received
  local client = vim.uv.new_pipe(false)
  client:connect(path, function(connect_err)
    assert(not connect_err, connect_err)
    client:write(assert(framing.encode({ type = "request", requestId = "round-trip", version = 0, method = "ide-context", params = { workspaceRoot = "/repo" } })))
    local read = framing.decoder(function(message) received = message; client:read_stop(); client:close() end, error)
    client:read_start(function(read_err, data) assert(not read_err, read_err); if data then read(data) end end)
  end)
  assert(vim.wait(2000, function() return received ~= nil end, 10), "socket response timed out")
  eq(received.requestId, "round-trip")
  eq(received.result.ideContext.activeFile.path, "a😀.lua")
  server.stop()
end
print("codex_ide_spec: ok")
