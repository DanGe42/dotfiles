local M = { active_buf = nil, active_cursor = nil, selection = nil }

local function is_file_buffer(buf)
  return vim.api.nvim_buf_is_valid(buf)
    and vim.bo[buf].buflisted
    and vim.bo[buf].buftype == ""
    and vim.api.nvim_buf_get_name(buf) ~= ""
end

local function utf16(line, byte_col)
  return vim.str_utfindex(line:sub(1, byte_col), "utf-16")
end

local function pos(buf, p)
  local line = vim.api.nvim_buf_get_lines(buf, p[2] - 1, p[2], false)[1] or ""
  return { line = p[2] - 1, character = utf16(line, p[3] - 1) }
end

local function after_text(start, lines)
  if #lines == 1 then
    return { line = start.line, character = start.character + vim.str_utfindex(lines[1], "utf-16") }
  end
  return { line = start.line + #lines - 1, character = vim.str_utfindex(lines[#lines], "utf-16") }
end

local function capture(buf, mode, start, finish)
  if not is_file_buffer(buf) then return end
  local ok, lines = pcall(vim.fn.getregion, start, finish, { type = mode })
  local ok_pos, regions = pcall(vim.fn.getregionpos, start, finish, { type = mode })
  if not ok or not ok_pos or not regions[1] then return end
  local first_start = pos(buf, regions[1][1])
  local finish
  if mode == "V" then
    first_start.character = 0
    finish = { line = first_start.line + #lines, character = 0 }
  else
    finish = after_text(first_start, lines)
  end
  -- `selections` means multiple independent editor selections. A linewise
  -- Visual selection is still one selection; getregionpos happens to return a
  -- region for every line, which must not be exposed as a multi-cursor set.
  local ranges = {}
  if mode == "\22" and #regions == #lines then
    for index, region in ipairs(regions) do
      local range_start = pos(buf, region[1])
      ranges[index] = { start = range_start, ["end"] = after_text(range_start, { lines[index] }) }
    end
  end
  M.active_buf = buf
  M.selection = {
    buf = buf,
    -- Leaving Visual mode can emit one CursorMoved for the same editor
    -- position after the selection has been captured. Keep the selection for
    -- that transition, then clear it on the next actual cursor movement.
    ignore_cursor_once = true,
    text = table.concat(lines, "\n"),
    start = first_start,
    finish = finish,
    ranges = ranges,
  }
end

-- Save before focus moves to the terminal. '< and '> are only finalized after
-- Visual mode exits, so an in-mode mapping must use Visual's live anchor and
-- cursor instead.
function M.capture_visual()
  local mode = vim.fn.mode(1)
  if not mode:match("^[vV\22]") then return end
  return capture(vim.api.nvim_get_current_buf(), mode, vim.fn.getpos("v"), vim.fn.getpos("."))
end

function M.note_focus()
  local buf = vim.api.nvim_get_current_buf()
  if is_file_buffer(buf) then
    if M.selection and M.selection.buf ~= buf then M.selection = nil end
    M.active_buf = buf
    M.active_cursor = vim.api.nvim_win_get_cursor(0)
  end
end

function M.clear_selection(args)
  if M.selection and args and args.event == "CursorMoved" and args.buf == M.selection.buf and M.selection.ignore_cursor_once then
    M.selection.ignore_cursor_once = nil
    return
  end
  if not M.selection or not args or not args.buf or args.buf == M.selection.buf then
    M.selection = nil
  end
end

local function path_for(name, root)
  name = vim.fn.fnamemodify(name, ":p")
  root = root and vim.fn.fnamemodify(root, ":p") or nil
  if root and (name == root or name:sub(1, #root + 1) == root .. "/") then
    return name == root and "." or name:sub(#root + 2)
  end
  return name
end

local function tab(buf, root)
  local name = vim.api.nvim_buf_get_name(buf)
  return { label = vim.fn.fnamemodify(name, ":t"), path = path_for(name, root), fsPath = vim.fn.fnamemodify(name, ":p") }
end

function M.snapshot(workspace_root)
  M.note_focus()
  local active = M.active_buf
  local active_file
  if active and is_file_buffer(active) then
    active_file = tab(active, workspace_root)
    local cursor = M.active_cursor or { 1, 0 }
    local line = vim.api.nvim_buf_get_lines(active, cursor[1] - 1, cursor[1], false)[1] or ""
    local here = { line = cursor[1] - 1, character = utf16(line, cursor[2]) }
    local selection = M.selection or { start = here, finish = here, text = "" }
    active_file.selection = { start = selection.start, ["end"] = selection.finish }
    active_file.activeSelectionContent = selection.text
    active_file.selections = selection.ranges or {}
  end
  local open_tabs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_file_buffer(buf) then table.insert(open_tabs, tab(buf, workspace_root)) end
  end
  return { activeFile = active_file, openTabs = open_tabs }
end

function M.setup()
  local group = vim.api.nvim_create_augroup("CodexIdeContext", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, { group = group, callback = M.note_focus })
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = group,
    callback = function(args)
      if vim.fn.mode(1):match("^[vV\22]") then
        M.capture_visual()
      else
        M.clear_selection(args)
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "CursorMovedI", "TextChanged" }, {
    group = group, callback = M.clear_selection,
  })
  -- Capture immediately on entering Visual mode (which selects at least the
  -- cursor character), then CursorMoved above keeps it current as it grows.
  vim.api.nvim_create_autocmd("ModeChanged", {
    group = group,
    callback = function(args)
      local new_mode = vim.v.event.new_mode or args.match:match(":(.-)$")
      M.visual_tracking = new_mode and new_mode:match("^[vV\22]") ~= nil
      if M.visual_tracking then
        vim.schedule(M.capture_visual)
      end
    end,
  })
  -- CursorMoved is not emitted for every Visual-mode extension. on_key runs
  -- for those keys too; defer editor API work out of its fast-event context.
  vim.on_key(function()
    if M.visual_tracking then vim.schedule(M.capture_visual) end
  end, vim.api.nvim_create_namespace("CodexIdeVisualTracking"))
end

return M
