---@class CursorAgentUiOpts
---@field border? string
---@field width? number
---@field height? number
---@field display? "float" | "split" | "quickfix"

---@class CursorAgentPrompts
---@field daily? string

---@class CursorAgentRepo
---@field url string
---@field startingRef? string
---@field prUrl? string

---@class CursorAgentModelConfig
---@field id string
---@field params? table[]

---@class CursorAgentConfig
---@field api_key? string
---@field api_key_env? string
---@field base_url? string
---@field default_agent? string
---@field agent_name? string
---@field model? string|CursorAgentModelConfig
---@field favorite_models? string[]
---@field repos? CursorAgentRepo[]
---@field auto_detect_repo? boolean
---@field reuse_agent? boolean
---@field polling_interval? number
---@field max_poll_attempts? number
---@field request_timeout_ms? number
---@field retry? { max_attempts?: number, base_delay_ms?: number, max_delay_ms?: number }
---@field log_level? "debug" | "info" | "warn" | "error" | "off"
---@field ui? CursorAgentUiOpts
---@field prompts? CursorAgentPrompts
---@field workOnCurrentBranch? boolean
---@field autoCreatePR? boolean
---@field mode? "agent" | "plan"

local M = {}

---@type CursorAgentConfig
M.defaults = {
  api_key = nil,
  api_key_env = "CURSOR_API_KEY",
  base_url = "https://api.cursor.com/v1",
  default_agent = nil,
  agent_name = nil,
  model = nil,
  favorite_models = nil,
  repos = nil,
  auto_detect_repo = true,
  reuse_agent = true,
  polling_interval = 2,
  max_poll_attempts = 900,
  request_timeout_ms = 60000,
  retry = {
    max_attempts = 4,
    base_delay_ms = 500,
    max_delay_ms = 8000,
  },
  log_level = "info",
  ui = {
    border = "rounded",
    width = 0.8,
    height = 0.8,
    display = "float",
  },
  prompts = {
    daily = [[
Analyze the current project.
Review git changes.
Suggest next development tasks.
Check for TODOs.
Summarize blockers.
]],
  },
  workOnCurrentBranch = false,
  autoCreatePR = false,
  mode = "agent",
}

---@type CursorAgentConfig
M.options = vim.deepcopy(M.defaults)

---@param user_opts? CursorAgentConfig
function M.setup(user_opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), user_opts or {})
end

---@return CursorAgentConfig
function M.get()
  return M.options
end

---@return string?
function M.get_api_key()
  local opts = M.options
  if opts.api_key and opts.api_key ~= "" then
    return opts.api_key
  end

  local env_name = opts.api_key_env or "CURSOR_API_KEY"
  local from_env = vim.env[env_name]
  if from_env and from_env ~= "" then
    return from_env
  end

  return nil
end

---@return string
function M.get_base_url()
  local base = M.options.base_url or M.defaults.base_url
  return base:gsub("/+$", "")
end

---@param errs string[]
---@param condition boolean
---@param message string
local function check(errs, condition, message)
  if not condition then
    errs[#errs + 1] = message
  end
end

---@return boolean ok
---@return string[]? errors
function M.validate()
  local opts = M.options
  local errs = {}

  check(errs, M.get_api_key() ~= nil, "api_key is required (set api_key or " .. (opts.api_key_env or "CURSOR_API_KEY") .. " env var)")

  if opts.polling_interval then
    check(errs, opts.polling_interval > 0, "polling_interval must be positive")
  end

  if opts.max_poll_attempts then
    check(errs, opts.max_poll_attempts > 0, "max_poll_attempts must be positive")
  end

  if opts.ui then
    if opts.ui.width then
      check(errs, opts.ui.width > 0 and opts.ui.width <= 1, "ui.width must be between 0 and 1")
    end
    if opts.ui.height then
      check(errs, opts.ui.height > 0 and opts.ui.height <= 1, "ui.height must be between 0 and 1")
    end
    if opts.ui.display then
      check(
        errs,
        vim.tbl_contains({ "float", "split", "quickfix" }, opts.ui.display),
        "ui.display must be one of: float, split, quickfix"
      )
    end
  end

  if #errs > 0 then
  error("cursor-agent.nvim: invalid configuration:\n- " .. table.concat(errs, "\n- "), 0)
  end

  return true, errs
end

return M
