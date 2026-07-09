local config = require("turbo-log.config")
local context = require("turbo-log.context")
local detect = require("turbo-log.detect")
local message = require("turbo-log.message")
local langs = require("turbo-log.languages")

local M = {}

local function comment_prefix(ft)
  if ft == "python" or ft == "php" then
    return "# "
  end
  return "// "
end

local function uncomment_line(line, ft)
  local trimmed = vim.trim(line)
  if ft == "python" or ft == "php" then
    if trimmed:sub(1, 1) == "#" then
      local indent = line:match("^(%s*)") or ""
      return indent .. trimmed:sub(2):gsub("^%s*", "")
    end
  else
    if trimmed:sub(1, 2) == "//" then
      local indent = line:match("^(%s*)") or ""
      return indent .. trimmed:sub(3):gsub("^%s*", "")
    end
  end
  return line
end

local function comment_line(line, ft)
  local trimmed = vim.trim(line)
  if ft == "python" or ft == "php" then
    if trimmed:sub(1, 1) == "#" then
      return line
    end
  elseif trimmed:sub(1, 2) == "//" then
    return line
  end
  local indent = line:match("^(%s*)") or ""
  return indent .. comment_prefix(ft) .. trimmed
end

local function guard_buf(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  if not langs.for_filetype(ft) then
    vim.notify("turbo-log: unsupported filetype " .. ft, vim.log.levels.WARN)
    return nil
  end
  return buf, ft
end

local function comment_range(buf, ft, start_lnum, end_lnum)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i = start_lnum, end_lnum do
    lines[i] = comment_line(lines[i], ft)
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

local function uncomment_range(buf, ft, start_lnum, end_lnum)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i = start_lnum, end_lnum do
    lines[i] = uncomment_line(lines[i], ft)
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

function M.comment_all(buf)
  local guarded, ft = guard_buf(buf)
  if not guarded then
    return
  end
  buf = guarded
  local groups = detect.log_groups(buf)
  for i = #groups, 1, -1 do
    comment_range(buf, ft, groups[i].start_lnum, groups[i].end_lnum)
  end
end

function M.uncomment_all(buf)
  local guarded, ft = guard_buf(buf)
  if not guarded then
    return
  end
  buf = guarded
  local groups = detect.log_groups(buf)
  for i = #groups, 1, -1 do
    uncomment_range(buf, ft, groups[i].start_lnum, groups[i].end_lnum)
  end
end

function M.delete_all(buf)
  local guarded = guard_buf(buf)
  if not guarded then
    return
  end
  buf = guarded
  local groups = detect.log_groups(buf)
  for i = #groups, 1, -1 do
    local g = groups[i]
    vim.api.nvim_buf_set_lines(buf, g.start_lnum - 1, g.end_lnum, false, {})
  end
end

local function correct_group_range(buf, ft, g)
  local line = vim.api.nvim_buf_get_lines(buf, g.content_lnum - 1, g.content_lnum, false)[1] or ""
  local uncommented = uncomment_line(line, ft)
  local var = detect.extract_var(uncommented, ft)
  if not var then
    return false
  end

  local method = detect.extract_method(uncommented, ft)
  local ctx = context.get(buf, g.content_lnum - 1, 0, ft)
  local indent = line:match("^(%s*)") or ""
  local built = message.build_lines(method, var, ctx, g.content_lnum, ft)
  local new_lines = {}
  for _, built_line in ipairs(built) do
    local out = indent .. built_line
    if vim.trim(line) ~= uncommented then
      out = comment_line(out, ft)
    end
    new_lines[#new_lines + 1] = out
  end

  vim.api.nvim_buf_set_lines(buf, g.start_lnum - 1, g.end_lnum, false, new_lines)
  return true
end

function M.correct_group(buf, entry)
  local guarded, ft = guard_buf(buf)
  if not guarded then
    return false
  end
  buf = guarded
  entry = entry or {}

  if entry.start_lnum and entry.end_lnum then
    return correct_group_range(buf, ft, {
      start_lnum = entry.start_lnum,
      end_lnum = entry.end_lnum,
      content_lnum = entry.lnum,
    })
  end

  for _, g in ipairs(detect.log_groups(buf)) do
    if g.content_lnum == entry.lnum or (entry.lnum and entry.lnum >= g.start_lnum and entry.lnum <= g.end_lnum) then
      return correct_group_range(buf, ft, g)
    end
  end

  vim.notify("turbo-log: could not locate log in buffer", vim.log.levels.WARN)
  return false
end

function M.correct_all(buf)
  local guarded, ft = guard_buf(buf)
  if not guarded then
    return
  end
  buf = guarded
  local groups = detect.log_groups(buf)

  for i = #groups, 1, -1 do
    correct_group_range(buf, ft, groups[i])
  end
end

return M
