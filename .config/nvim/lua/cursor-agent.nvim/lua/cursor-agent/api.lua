local config = require("cursor-agent.config")
local utils = require("cursor-agent.utils")

---@class CursorAgentApiClient
---@field config table
---@field http_request? fun(method: string, path: string, body?: table, cb?: fun(err?: string, data?: table, status?: number))
local M = {}
M.__index = M

---@param overrides? table
---@return CursorAgentApiClient
function M.new(overrides)
  local instance = setmetatable({}, M)
  instance.config = vim.tbl_deep_extend("force", config.get(), overrides or {})
  return instance
end

---@param client CursorAgentApiClient
---@param method string
---@param path string
---@param body? table
---@param done fun(err?: string, data?: table, status?: number)
function M.request(client, method, path, body, done)
  if client.http_request then
    client.http_request(method, path, body, done)
    return
  end

  local api_key = config.get_api_key()
  if not api_key then
    local ok, err = pcall(config.validate)
    if not ok then
      done(err, nil, nil)
      return
    end
  end

  if not api_key then
    done("API key is not configured", nil, nil)
    return
  end

  local url = utils.join_url(config.get_base_url(), path)
  local headers = {
    "Authorization: Bearer " .. api_key,
    "Content-Type: application/json",
    "Accept: application/json",
  }

  local args = {
    "curl",
    "-sS",
    "-X",
    method,
    "-w",
    "\n__HTTP_STATUS__:%{http_code}",
    "--max-time",
    tostring(math.floor((client.config.request_timeout_ms or 60000) / 1000)),
  }

  for _, header in ipairs(headers) do
    args[#args + 1] = "-H"
    args[#args + 1] = header
  end

  if body ~= nil then
    local encoded, encode_err = utils.json_encode(body)
    if not encoded then
      done(encode_err, nil, nil)
      return
    end
    args[#args + 1] = "--data"
    args[#args + 1] = encoded
  end

  args[#args + 1] = url

  vim.system(args, { text = true }, function(obj)
    if obj.code ~= 0 then
      done("HTTP request failed: " .. (obj.stderr or obj.stdout or "unknown curl error"), nil, nil)
      return
    end

    local stdout = obj.stdout or ""
    local status_line = stdout:match("\n__HTTP_STATUS__:(%d+)%s*$")
    local response_body = stdout:gsub("\n__HTTP_STATUS__:%d+%s*$", "")

    local status = tonumber(status_line or "0") or 0
    local decoded, decode_err = utils.json_decode(response_body ~= "" and response_body or nil)

    if status >= 200 and status < 300 then
      done(nil, decoded or {}, status)
      return
    end

    local api_message = decoded and (decoded.message or decoded.error or decoded.code)
    local err = string.format(
      "API error (%d): %s",
      status,
      utils.format_api_error(decoded or api_message or response_body)
    )
    done(err, decoded, status)
  end)
end

---@param client CursorAgentApiClient
---@param method string
---@param path string
---@param body? table
---@param done fun(err?: string, data?: table)
function M.request_with_retry(client, method, path, body, done)
  utils.with_retry(client.config, function(cb)
    M.request(client, method, path, body, cb)
  end, done)
end

---@param client CursorAgentApiClient
---@param done fun(err?: string, data?: table)
function M.me(client, done)
  M.request_with_retry(client, "GET", "/me", nil, done)
end

---@param client CursorAgentApiClient
---@param done fun(err?: string, data?: table)
function M.list_models(client, done)
  M.request_with_retry(client, "GET", "/models", nil, done)
end

---@param model any
---@return table|nil
local function sanitize_model(model)
  if model == nil then
    return nil
  end

  if type(model) == "string" then
    if model == "" or model == "default" or model == "auto" then
      return nil
    end
    return { id = model }
  end

  if type(model) ~= "table" or type(model.id) ~= "string" or model.id == "" then
    return nil
  end

  if model.id == "default" or model.id == "auto" then
    return nil
  end

  local payload = { id = model.id }
  local params = utils.normalize_model_params(model.params)
  if params then
    payload.params = params
  end

  return payload
end

---@param client CursorAgentApiClient
---@param prompt_text string
---@param opts? table
---@param done fun(err?: string, data?: { agent: table, run: table })
function M.create_agent(client, prompt_text, opts, done)
  opts = opts or {}

  local body = {
    prompt = { text = prompt_text },
    mode = opts.mode or client.config.mode or "agent",
    workOnCurrentBranch = opts.workOnCurrentBranch or client.config.workOnCurrentBranch,
    autoCreatePR = opts.autoCreatePR or client.config.autoCreatePR,
  }

  if opts.name or client.config.agent_name then
    body.name = opts.name or client.config.agent_name
  end

  local models = require("cursor-agent.models")
  local model = sanitize_model(models.resolve_for_create(opts))
  if model then
    body.model = model
  end

  local repos = utils.sanitize_repos(opts.repos) or utils.resolve_configured_repos(client.config)
  if repos then
    body.repos = repos
  end

  if client.config.log_level == "debug" then
    utils.log(client.config, "debug", "create agent payload: " .. (utils.json_encode(body) or ""))
  end

  M.request_with_retry(client, "POST", "/agents", body, done)
end

---@param client CursorAgentApiClient
---@param agent_id string
---@param done fun(err?: string, data?: table)
function M.get_agent(client, agent_id, done)
  M.request_with_retry(client, "GET", "/agents/" .. utils.url_encode(agent_id), nil, done)
end

---@param client CursorAgentApiClient
---@param query? table
---@param done fun(err?: string, data?: table)
function M.list_agents(client, query, done)
  local params = {}
  if query then
    for key, value in pairs(query) do
      if value ~= nil then
        params[#params + 1] = utils.url_encode(key) .. "=" .. utils.url_encode(tostring(value))
      end
    end
  end

  local path = "/agents"
  if #params > 0 then
    path = path .. "?" .. table.concat(params, "&")
  end

  M.request_with_retry(client, "GET", path, nil, done)
end

---@param client CursorAgentApiClient
---@param name_or_id string
---@param done fun(err?: string, agent?: table)
function M.find_agent(client, name_or_id, done)
  if name_or_id:match("^bc%-") then
    M.get_agent(client, name_or_id, function(err, agent)
      if err then
        done(err, nil)
        return
      end
      done(nil, agent)
    end)
    return
  end

  M.list_agents(client, { limit = 100 }, function(err, data)
    if err then
      done(err, nil)
      return
    end

    for _, agent in ipairs(data.items or {}) do
      if agent.name == name_or_id or agent.id == name_or_id then
        done(nil, agent)
        return
      end
    end

    done("agent not found: " .. name_or_id, nil)
  end)
end

---@param client CursorAgentApiClient
---@param agent_id string
---@param prompt_text string
---@param opts? table
---@param done fun(err?: string, data?: { run: table })
function M.create_run(client, agent_id, prompt_text, opts, done)
  opts = opts or {}
  local body = {
    prompt = { text = prompt_text },
    mode = opts.mode,
  }

  M.request_with_retry(client, "POST", "/agents/" .. utils.url_encode(agent_id) .. "/runs", body, function(err, data, status)
    if err and status == 409 then
      done("agent is busy with another run; wait or cancel it before sending a new prompt", data, status)
      return
    end
    done(err, data)
  end)
end

---@param client CursorAgentApiClient
---@param agent_id string
---@param run_id string
---@param done fun(err?: string, run?: table)
function M.get_run(client, agent_id, run_id, done)
  local path = "/agents/" .. utils.url_encode(agent_id) .. "/runs/" .. utils.url_encode(run_id)
  M.request_with_retry(client, "GET", path, nil, function(err, data)
    done(err, data)
  end)
end

---@param client CursorAgentApiClient
---@param agent_id string
---@param run_id string
---@param done fun(err?: string, data?: table)
function M.cancel_run(client, agent_id, run_id, done)
  local path = "/agents/" .. utils.url_encode(agent_id) .. "/runs/" .. utils.url_encode(run_id) .. "/cancel"
  M.request_with_retry(client, "POST", path, {}, done)
end

---@param client CursorAgentApiClient
---@param agent_id string
---@param run_id string
---@param on_update? fun(run: table)
---@param done fun(err?: string, run?: table)
function M.poll_run(client, agent_id, run_id, on_update, done)
  local attempts = 0
  local max_attempts = client.config.max_poll_attempts or 900
  local interval_ms = math.floor((client.config.polling_interval or 2) * 1000)

  local function poll()
    attempts = attempts + 1
    if attempts > max_attempts then
      done("polling timed out after " .. tostring(max_attempts) .. " attempts", nil)
      return
    end

    M.get_run(client, agent_id, run_id, function(err, run)
      if err then
        done(err, nil)
        return
      end

      if on_update then
        on_update(run)
      end

      if utils.is_terminal_run_status(run.status) then
        if run.status == "FINISHED" then
          done(nil, run)
        else
          done("run ended with status " .. tostring(run.status) .. ": " .. (run.result or "no result"), run)
        end
        return
      end

      vim.defer_fn(poll, interval_ms)
    end)
  end

  poll()
end

return M
