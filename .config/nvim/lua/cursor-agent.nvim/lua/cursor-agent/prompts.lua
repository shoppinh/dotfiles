local config = require("cursor-agent.config")

local M = {}

---@param name string
---@return string|nil
function M.get_named_prompt(name)
  local prompts = config.get().prompts or {}
  local text = prompts[name]
  if text and text ~= "" then
    return vim.trim(text)
  end
  return nil
end

---@return string
function M.get_daily_prompt()
  local daily = M.get_named_prompt("daily")
  if daily then
    return daily
  end

  return vim.trim((config.defaults.prompts or {}).daily or "")
end

---@param text string
---@return string
function M.normalize_prompt(text)
  return vim.trim(text)
end

---@param text string|nil
---@return string|nil err
function M.validate_prompt(text)
  if text == nil or vim.trim(text) == "" then
    return "prompt text is required"
  end
  return nil
end

return M
