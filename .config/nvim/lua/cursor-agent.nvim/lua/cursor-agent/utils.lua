local M = {}

local LEVELS = { debug = 1, info = 2, warn = 3, error = 4, off = 99 }

---@param level string
---@return number
function M.level_value(level)
  return LEVELS[level] or LEVELS.info
end

---@param config table
---@param level string
---@param message string
function M.log(config, level, message)
  local configured = M.level_value(config.log_level or "info")
  local current = M.level_value(level)
  if current < configured then
    return
  end

  vim.notify(string.format("[cursor-agent] %s", message), vim.log.levels[level:upper()] or vim.log.levels.INFO)
end

---@param tbl table
---@return table
function M.deep_copy(tbl)
  if type(tbl) ~= "table" then
    return tbl
  end

  local copy = {}
  for key, value in pairs(tbl) do
    copy[key] = M.deep_copy(value)
  end
  return copy
end

---@param data any
---@return string|nil decoded
---@return string|nil err
function M.json_decode(data)
  if data == nil or data == "" then
    return nil, "empty response body"
  end

  local ok, decoded = pcall(vim.json.decode, data)
  if not ok then
    return nil, "failed to decode JSON: " .. tostring(decoded)
  end

  return decoded, nil
end

---@param data any
---@return string|nil encoded
---@return string|nil err
function M.json_encode(data)
  local ok, encoded = pcall(vim.json.encode, data)
  if not ok then
    return nil, "failed to encode JSON: " .. tostring(encoded)
  end
  return encoded, nil
end

---@param path string
---@return string encoded
function M.url_encode(path)
  return (path:gsub("[^%w%-%.%_%~]", function(char)
    return string.format("%%%02X", string.byte(char))
  end))
end

---@param base string
---@param path string
---@return string
function M.join_url(base, path)
  local sanitized_base = base:gsub("/+$", "")
  local sanitized_path = (path or ""):gsub("^/+", ""):gsub("/+$", "")
  if sanitized_path == "" then
    return sanitized_base
  end
  return sanitized_base .. "/" .. sanitized_path
end

---@param status number
---@return boolean
function M.is_retryable_status(status)
  return status == 408 or status == 429 or status >= 500
end

---@param config table
---@param attempt number
---@return number
function M.backoff_ms(config, attempt)
  local retry = config.retry or {}
  local base = retry.base_delay_ms or 500
  local max_delay = retry.max_delay_ms or 8000
  local delay = base * (2 ^ math.max(0, attempt - 1))
  return math.min(delay, max_delay)
end

---@generic T
---@param config table
---@param fn fun(done: fun(err?: string, result?: T))
---@param done fun(err?: string, result?: T)
function M.with_retry(config, fn, done)
  local retry = config.retry or {}
  local max_attempts = retry.max_attempts or 1
  local attempt = 0

  local function run()
    attempt = attempt + 1
    fn(function(err, result, status)
      if not err then
        done(nil, result)
        return
      end

      local retryable = status ~= nil and M.is_retryable_status(status)
      if retryable and attempt < max_attempts then
        local delay = M.backoff_ms(config, attempt)
        M.log(config, "warn", string.format("retrying request (%d/%d) in %dms: %s", attempt, max_attempts, delay, err))
        vim.defer_fn(run, delay)
        return
      end

      done(err, result)
    end)
  end

  run()
end

---@param statuses string[]
---@param status string|nil
---@return boolean
function M.is_terminal_run_status(status)
  return vim.tbl_contains({ "FINISHED", "ERROR", "CANCELLED", "EXPIRED" }, status or "")
end

---@param statuses string[]
---@param status string|nil
---@return boolean
function M.is_active_run_status(status)
  return vim.tbl_contains({ "CREATING", "RUNNING" }, status or "")
end

---@param fn fun()
function M.schedule(fn)
  if vim.in_fast_event() then
    vim.schedule(fn)
  else
    fn()
  end
end

---@param cwd? string
---@return string|nil remote_url
---@return string|nil branch
function M.detect_git_repo(cwd)
  cwd = cwd or (vim.uv and vim.uv.cwd()) or vim.fn.getcwd()
  if not cwd or cwd == "" then
    return nil, nil
  end

  local inside = vim.fn.systemlist({ "git", "-C", cwd, "rev-parse", "--is-inside-work-tree" })
  if vim.v.shell_error ~= 0 or inside[1] ~= "true" then
    return nil, nil
  end

  local remote = vim.fn.systemlist({ "git", "-C", cwd, "remote", "get-url", "origin" })
  if vim.v.shell_error ~= 0 or remote[1] == nil then
    return nil, nil
  end

  local branch = vim.fn.systemlist({ "git", "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD" })
  local branch_name = vim.v.shell_error == 0 and branch[1] or "main"

  local url = remote[1]
  url = url:gsub("^git@github.com:", "https://github.com/")
  url = url:gsub("%.git$", "")

  return url, branch_name
end

---@param repo table
---@return table|nil
local function sanitize_repo_entry(repo)
  if type(repo) == "string" and repo ~= "" then
    return { url = repo }
  end

  if type(repo) ~= "table" or type(repo.url) ~= "string" or repo.url == "" then
    return nil
  end

  local entry = { url = repo.url }
  if repo.startingRef then
    entry.startingRef = repo.startingRef
  end
  if repo.prUrl then
    entry.prUrl = repo.prUrl
  end
  return entry
end

---@param repos any
---@return table[]|nil
function M.sanitize_repos(repos)
  if repos == nil then
    return nil
  end

  if type(repos) == "string" then
    return { sanitize_repo_entry(repos) }
  end

  if type(repos) ~= "table" then
    return nil
  end

  if repos.url then
    local single = sanitize_repo_entry(repos)
    return single and { single } or nil
  end

  local items = {}
  for _, repo in ipairs(repos) do
    local entry = sanitize_repo_entry(repo)
    if entry then
      items[#items + 1] = entry
    end
  end

  if #items > 0 then
    return items
  end

  return nil
end

---@param config table
---@return table[]|nil
function M.resolve_configured_repos(config)
  if not config.repos then
    return nil
  end
  return M.sanitize_repos(config.repos)
end

---@param config table
---@return table[]|nil
function M.resolve_repos(config)
  local configured = M.resolve_configured_repos(config)
  if configured then
    return configured
  end

  if not config.auto_detect_repo then
    return nil
  end

  local url, branch = M.detect_git_repo()
  if not url then
    return nil
  end

  return {
    {
      url = url,
      startingRef = branch,
    },
  }
end

---@param params any
---@return table[]|nil
function M.normalize_model_params(params)
  if params == nil or type(params) ~= "table" then
    return nil
  end

  local normalized = {}

  local function add_param(id, value)
    if id == nil or value == nil then
      return
    end
    normalized[#normalized + 1] = {
      id = tostring(id),
      value = value,
    }
  end

  if params.id ~= nil and params.value ~= nil and params[1] == nil then
    add_param(params.id, params.value)
    return normalized
  end

  if params[1] ~= nil then
    for _, param in ipairs(params) do
      if type(param) == "table" then
        add_param(param.id, param.value)
      end
    end
    if #normalized > 0 then
      return normalized
    end
  end

  for key, value in pairs(params) do
    if type(key) == "string" and key ~= "id" and key ~= "value" then
      add_param(key, value)
    end
  end

  if #normalized > 0 then
    return normalized
  end

  return nil
end

---@param err any
---@return string
function M.format_api_error(err)
  if type(err) == "string" then
    return err
  end

  if type(err) == "table" then
    local parts = {}
    if err.error then
      parts[#parts + 1] = tostring(err.error)
    end
    if err.message and err.message ~= "" and err.message ~= "Error" then
      parts[#parts + 1] = tostring(err.message)
    end
    if err.code and err.code ~= err.error and err.code ~= err.message then
      parts[#parts + 1] = tostring(err.code)
    end
    if err.path then
      local path = type(err.path) == "table" and table.concat(err.path, ".") or tostring(err.path)
      parts[#parts + 1] = "path: " .. path
    end
    if err.details then
      parts[#parts + 1] = vim.inspect(err.details)
    end
    if #parts > 0 then
      return table.concat(parts, " — ")
    end
    local encoded = M.json_encode(err)
    if encoded then
      return encoded
    end
  end

  return tostring(err)
end

return M
