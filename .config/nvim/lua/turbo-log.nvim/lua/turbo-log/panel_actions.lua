local bulk = require("turbo-log.bulk")
local detect = require("turbo-log.detect")

local M = {}

local function ensure_buf_ft(buf)
  if vim.bo[buf].filetype ~= "" then
    return
  end
  vim.api.nvim_buf_call(buf, function()
    local ft = vim.filetype.match({ buf = buf })
    if ft then
      vim.bo[buf].filetype = ft
    end
  end)
end

function M.entry_from_item(item)
  if not item then
    return nil
  end
  local data = item.item or {}
  return {
    path = item.filename or data.path,
    lnum = item.pos and item.pos[1] or data.lnum,
    line = item.text or data.line or "",
    start_lnum = data.start_lnum,
    end_lnum = data.end_lnum,
  }
end

function M.resolve_group(buf, entry)
  if entry.start_lnum and entry.end_lnum then
    return entry.start_lnum, entry.end_lnum
  end

  ensure_buf_ft(buf)
  for _, g in ipairs(detect.log_groups(buf)) do
    if g.content_lnum == entry.lnum or (entry.lnum >= g.start_lnum and entry.lnum <= g.end_lnum) then
      return g.start_lnum, g.end_lnum
    end
  end

  return nil, nil
end

function M.with_entry_buf(entry, fn)
  local path = vim.fs.normalize(entry.path)
  if vim.fn.filereadable(path) ~= 1 then
    vim.notify("turbo-log: file not found: " .. path, vim.log.levels.ERROR)
    return false
  end

  local buf = vim.fn.bufadd(path)
  if buf == -1 then
    return false
  end
  if not vim.api.nvim_buf_is_loaded(buf) then
    vim.fn.bufload(buf)
  end
  ensure_buf_ft(buf)

  local ok = false
  vim.api.nvim_buf_call(buf, function()
    ok = fn(buf) ~= false
  end)

  if not ok then
    return false
  end

  if vim.api.nvim_buf_get_option(buf, "modified") then
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("silent! write")
    end)
  end

  return true
end

function M.delete_entry(entry)
  return M.with_entry_buf(entry, function(buf)
    local start_lnum, end_lnum = M.resolve_group(buf, entry)
    if not start_lnum then
      vim.notify("turbo-log: could not locate log in buffer", vim.log.levels.WARN)
      return false
    end
    vim.api.nvim_buf_set_lines(buf, start_lnum - 1, end_lnum, false, {})
    return true
  end)
end

function M.comment_entry(entry)
  return M.with_entry_buf(entry, function(buf)
    local ft = vim.bo[buf].filetype
    local start_lnum, end_lnum = M.resolve_group(buf, entry)
    if not start_lnum then
      vim.notify("turbo-log: could not locate log in buffer", vim.log.levels.WARN)
      return false
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local prefix = (ft == "python" or ft == "php") and "# " or "// "
    for i = start_lnum, end_lnum do
      local line = lines[i]
      if line and vim.trim(line) ~= "" then
        lines[i] = (line:match("^(%s*)") or "") .. prefix .. vim.trim(line)
      end
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    return true
  end)
end

function M.uncomment_entry(entry)
  return M.with_entry_buf(entry, function(buf)
    local ft = vim.bo[buf].filetype
    local start_lnum, end_lnum = M.resolve_group(buf, entry)
    if not start_lnum then
      vim.notify("turbo-log: could not locate log in buffer", vim.log.levels.WARN)
      return false
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for i = start_lnum, end_lnum do
      local line = lines[i]
      local trimmed = vim.trim(line)
      if ft == "python" or ft == "php" then
        if trimmed:sub(1, 1) == "#" then
          lines[i] = (line:match("^(%s*)") or "") .. trimmed:sub(2):gsub("^%s*", "")
        end
      elseif trimmed:sub(1, 2) == "//" then
        lines[i] = (line:match("^(%s*)") or "") .. trimmed:sub(3):gsub("^%s*", "")
      end
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    return true
  end)
end

function M.correct_entry(entry)
  return M.with_entry_buf(entry, function(buf)
    return bulk.correct_group(buf, entry)
  end)
end

local function collect_items(view, ctx)
  local items = {}
  local seen = {}

  local function add(item)
    if not item or not item.filename or not item.pos then
      return
    end
    local id = item.id or table.concat({ item.filename, item.pos[1], item.pos[2] }, ":")
    if not seen[id] then
      seen[id] = true
      items[#items + 1] = item
    end
  end

  if ctx.item then
    add(ctx.item)
  end

  if view and #items == 0 and type(view.selection) == "function" then
    for _, node in ipairs(view:selection()) do
      if node.item then
        add(node.item)
      end
      if node.items then
        for _, child in ipairs(node.items) do
          add(child)
        end
      end
    end
  end

  table.sort(items, function(a, b)
    if a.filename == b.filename then
      return (a.pos[1] or 0) > (b.pos[1] or 0)
    end
    return (a.filename or "") > (b.filename or "")
  end)

  return items
end

function M.run_on_item(action, desc)
  return function(view, ctx)
    local items = collect_items(view, ctx)
    if #items == 0 then
      vim.notify("turbo-log: select a log entry first", vim.log.levels.WARN)
      return
    end

    local changed = 0
    for _, item in ipairs(items) do
      local entry = M.entry_from_item(item)
      if entry and action(entry) then
        changed = changed + 1
      end
    end

    if changed > 0 then
      if view then
        view:refresh()
      end
      vim.notify(string.format("turbo-log: %s %d log(s)", desc, changed), vim.log.levels.INFO)
    end
  end
end

return M
