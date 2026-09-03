local uv, framing, context = vim.uv, require("codex_ide.framing"), require("codex_ide.context")
local home = require("codex_ide.home")
local M = { handle = nil, path = nil, owned = false, clients = {} }

local function socket_path()
  return home.get() .. "/ipc/ipc.sock"
end

local function secure_parent(path)
  local stat = uv.fs_stat(path)
  if not stat then
    if vim.fn.mkdir(path, "p", 448) == 0 and not uv.fs_stat(path) then return nil, "cannot create " .. path end
    local chmod_ok, chmod_err = uv.fs_chmod(path, 448)
    if not chmod_ok then return nil, chmod_err end
    stat = uv.fs_stat(path)
  end
  if not stat or stat.type ~= "directory" then return nil, "socket parent is not a directory: " .. path end
  if stat.uid ~= uv.os_get_passwd().uid then return nil, "socket parent is not owned by this user: " .. path end
  -- Refuse a directory writable by group/other. This is the boundary that keeps
  -- another local user from replacing the socket between checks.
  if bit.band(stat.mode, 18) ~= 0 then return nil, "socket parent is writable by another user: " .. path end
  return true
end

local function remove_owned()
  if M.owned and M.path then
    local stat = uv.fs_lstat(M.path)
    if stat and stat.type == "socket" then uv.fs_unlink(M.path) end
  end
  M.owned = false
end

local function response(request)
  local id = request.requestId
  if request.version ~= 0 then
    return { type = "response", requestId = id, resultType = "error", error = "request-version-mismatch" }
  end
  if request.type ~= "request" or request.method ~= "ide-context" then
    return { type = "response", requestId = id, resultType = "error", error = "no-handler-for-request" }
  end
  local root = request.params and request.params.workspaceRoot or request.workspaceRoot
  return {
    type = "response",
    requestId = id,
    resultType = "success",
    method = "ide-context",
    handledByClientId = "neovim-codex-ide",
    -- The TUI deserializes this field as the IPC result envelope, not merely
    -- as an arbitrary object. "broadcast" is required even though this
    -- minimal provider does not implement broadcast routing.
    result = { type = "broadcast", ideContext = context.snapshot(root) },
  }
end

local function serve(client)
  local timer = uv.new_timer()
  local closed = false
  local function close()
    if closed then return end
    closed = true; timer:stop(); timer:close(); client:read_stop(); client:close(); M.clients[client] = nil
  end
  timer:start(5000, 0, vim.schedule_wrap(close))
  local decode = framing.decoder(function(request)
    -- uv read callbacks are fast events. Context collection calls Neovim APIs,
    -- so it must run on the scheduled main-loop turn rather than here.
    vim.schedule(function()
      if closed or client:is_closing() then return end
      local data = framing.encode(response(request))
      if not data then return close() end
      client:write(data, function(write_err) if write_err then vim.schedule(close) end end)
    end)
  end, function() close() end)
  client:read_start(function(err, data)
    if err or not data then return close() end
    timer:stop(); timer:start(5000, 0, vim.schedule_wrap(close)); decode(data)
  end)
end

local function stale_socket(path)
  local probe, done, live = uv.new_pipe(false), false, false
  probe:connect(path, function(err)
    live = not err; done = true; probe:close()
  end)
  vim.wait(250, function() return done end, 10)
  if not done or live then return nil, "socket is owned by a running provider: " .. path end
  local stat = uv.fs_lstat(path)
  if not stat or stat.type ~= "socket" then return nil, "refusing to replace non-socket path: " .. path end
  return uv.fs_unlink(path)
end

function M.start(opts)
  if M.handle and not M.handle:is_closing() then return true end
  M.path = (opts and opts.path) or socket_path()
  local parent = vim.fn.fnamemodify(M.path, ":h")
  local parent_ok, parent_err = secure_parent(parent)
  if not parent_ok then return nil, parent_err end
  local stat = uv.fs_lstat(M.path)
  if stat then
    if stat.type ~= "socket" then return nil, "refusing to use non-socket path: " .. M.path end
    if stat.uid ~= uv.os_get_passwd().uid then return nil, "refusing socket not owned by this user: " .. M.path end
    local ok, err = stale_socket(M.path); if not ok then return nil, err end
  end
  local handle, err = uv.new_pipe(false), nil
  local ok; ok, err = handle:bind(M.path)
  if not ok then handle:close(); return nil, err end
  M.handle, M.owned = handle, true
  handle:listen(1, function(listen_err)
    if listen_err then return end
    local client = uv.new_pipe(false)
    handle:accept(client); M.clients[client] = true; serve(client)
  end)
  return true
end

function M.stop()
  for client in pairs(M.clients) do if not client:is_closing() then client:close() end end
  M.clients = {}
  if M.handle and not M.handle:is_closing() then M.handle:close() end
  M.handle = nil; remove_owned()
end

function M.status() return { running = M.handle ~= nil and not M.handle:is_closing(), path = M.path } end
-- Kept public primarily to make the protocol envelope independently testable.
M.response = response
return M
