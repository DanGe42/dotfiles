-- Codex IDE IPC uses a u32 little-endian byte length followed by UTF-8 JSON.
local M = { max_frame_bytes = 256 * 1024 * 1024 }

function M.encode(message)
  local payload = vim.json.encode(message)
  if #payload > M.max_frame_bytes then
    return nil, "frame exceeds 256 MiB"
  end
  local n = #payload
  return string.char(n % 256, math.floor(n / 256) % 256, math.floor(n / 65536) % 256, math.floor(n / 16777216) % 256) .. payload
end

function M.decoder(on_message, on_error)
  local buffer = ""
  local failed = false
  return function(chunk)
    if failed or not chunk then return end
    buffer = buffer .. chunk
    while #buffer >= 4 do
      local a, b, c, d = buffer:byte(1, 4)
      local length = a + b * 256 + c * 65536 + d * 16777216
      if length > M.max_frame_bytes then
        failed = true
        return on_error("frame exceeds 256 MiB")
      end
      if #buffer < length + 4 then return end
      local payload = buffer:sub(5, length + 4)
      buffer = buffer:sub(length + 5)
      local ok, message = pcall(vim.json.decode, payload)
      if not ok then
        failed = true
        return on_error("invalid JSON frame: " .. tostring(message))
      end
      on_message(message)
    end
  end
end

return M
