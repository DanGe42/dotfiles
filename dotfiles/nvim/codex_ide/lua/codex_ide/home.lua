-- A Codex home contains much more than IPC state. Give each Neovim instance
-- its own home so its Sidekick Codex process and its IDE provider share one
-- private socket, while linking the user-owned credentials/configuration and
-- resumable session store.
local uv = vim.uv
local M = { path = nil }

local function default_home()
  local configured = vim.env.CODEX_HOME
  return configured and configured ~= "" and configured or vim.fn.expand("~/.codex")
end

local function link_if_present(source, target)
  if uv.fs_lstat(target) or not uv.fs_lstat(source) then return end
  -- A relative link is not appropriate: the private home is in a temp path.
  uv.fs_symlink(source, target)
end

function M.get()
  if M.path then return M.path end
  -- tempname is per-process, short enough for Unix socket path limits, and the
  -- directory is created private instead of relying on a shared /tmp parent.
  local path = vim.fn.tempname() .. "-codex"
  assert(vim.fn.mkdir(path, "p", 448) ~= 0 or uv.fs_stat(path), "cannot create Codex IDE home")
  assert(uv.fs_chmod(path, 448), "cannot secure Codex IDE home")
  local shared = default_home()
  for _, entry in ipairs({
    "auth.json", ".credentials.json", "config.toml", "AGENTS.md", "skills", "agents", "rules", "themes",
    -- Codex's resume picker reads these paths directly. Sharing them keeps
    -- previous and newly-created sessions visible from every Sidekick Codex.
    "sessions", "archived_sessions", "session_index.jsonl", "history.jsonl",
  }) do
    link_if_present(shared .. "/" .. entry, path .. "/" .. entry)
  end
  M.path = path
  return path
end

return M
