local api = require("cursor-agent.api")
local config = require("cursor-agent.config")
local models = require("cursor-agent.models")
local prompts = require("cursor-agent.prompts")
local ui = require("cursor-agent.ui")
local utils = require("cursor-agent.utils")

local M = {}

---@class CursorAgentSession
---@field agent_id? string
---@field run_id? string
---@field agent? table
---@field run? table

local session = {}

---@return CursorAgentApiClient
function M.get_client()
  return api.new()
end

---@return CursorAgentSession
function M.get_session()
  return session
end

---@param agent table|nil
---@param run table|nil
local function update_session(agent, run)
  if agent then
    session.agent = agent
    session.agent_id = agent.id
  end
  if run then
    session.run = run
    session.run_id = run.id
  end
end

---@param err string|nil
---@param context string
local function handle_error(err, context)
  local message = context
  if err then
    message = context .. ": " .. err
  end
  ui.notify(message, "error")
end

---@param agent_id string
---@param run_id string
---@param title string
---@param on_complete? fun(run: table)
function M.poll_and_show(agent_id, run_id, title, on_complete)
  local client = M.get_client()
  ui.notify_progress(string.format("Polling run %s...", run_id))

  api.poll_run(client, agent_id, run_id, function(run)
    update_session(nil, run)
    ui.notify_progress(string.format("Run status: %s", run.status or "unknown"))
  end, function(err, run)
    update_session(nil, run)

    if err and not run then
      handle_error(err, "Failed while polling run")
      return
    end

    if err and run then
      ui.show_result(title, ui.format_run_status(run))
      handle_error(err, "Run completed with issues")
      return
    end

    ui.show_result(title, ui.format_run_status(run))
    if on_complete and run then
      on_complete(run)
    end
  end)
end

---@param prompt_text string
---@param title string
---@param opts? table
function M.send_prompt(prompt_text, title, opts)
  opts = opts or {}

  local ok, err = pcall(config.validate)
  if not ok then
    handle_error(err, "Configuration error")
    return
  end

  local prompt_err = prompts.validate_prompt(prompt_text)
  if prompt_err then
    handle_error(prompt_err, "Invalid prompt")
    return
  end

  local client = M.get_client()
  local cfg = config.get()
  local prompt_opts = vim.tbl_extend("force", opts, {
    repos = utils.resolve_repos(cfg),
  })

  local function start_run(agent_id)
    ui.notify_progress("Sending prompt to agent...")
    api.create_run(client, agent_id, prompt_text, prompt_opts, function(run_err, data)
      if run_err then
        handle_error(run_err, "Failed to create run")
        return
      end

      local run = data and data.run
      if not run or not run.id then
        handle_error("missing run id in API response", "Failed to create run")
        return
      end

      update_session(nil, run)
      M.poll_and_show(agent_id, run.id, title, prompt_opts.on_complete)
    end)
  end

  local function create_agent(prompt_text, create_opts, on_created)
    models.prepare_for_create(client, create_opts, function(model_err, model, warning)
      if model_err then
        handle_error(model_err, "Failed to validate model")
        return
      end

      local function run_create()
        if warning then
          ui.notify(warning, "warn")
        end

        api.create_agent(client, prompt_text, vim.tbl_extend("force", create_opts, {
          model = model,
        }), on_created)
      end

      utils.schedule(run_create)
    end)
  end

  local function reuse_or_create()
    if cfg.reuse_agent and session.agent_id then
      start_run(session.agent_id)
      return
    end

    if cfg.default_agent then
      ui.notify_progress("Resolving default agent...")
      api.find_agent(client, cfg.default_agent, function(find_err, agent)
        if find_err then
          ui.notify_progress("Default agent not found, creating a new agent...")
          create_agent(prompt_text, prompt_opts, function(create_err, data)
            if create_err then
              handle_error(create_err, "Failed to create agent")
              return
            end

            local agent_data = data and data.agent
            local run = data and data.run
            if not agent_data or not run then
              handle_error("invalid create agent response", "Failed to create agent")
              return
            end

            update_session(agent_data, run)
            M.poll_and_show(agent_data.id, run.id, title, opts.on_complete)
          end)
          return
        end

        update_session(agent, nil)
        start_run(agent.id)
      end)
      return
    end

    ui.notify_progress("Creating new agent...")
    create_agent(prompt_text, prompt_opts, function(create_err, data)
      if create_err then
        handle_error(create_err, "Failed to create agent")
        return
      end

      local agent_data = data and data.agent
      local run = data and data.run
      if not agent_data or not run then
        handle_error("invalid create agent response", "Failed to create agent")
        return
      end

      update_session(agent_data, run)
      M.poll_and_show(agent_data.id, run.id, title, opts.on_complete)
    end)
  end

  reuse_or_create()
end

function M.daily()
  local prompt_text = prompts.get_daily_prompt()
  M.send_prompt(prompt_text, "Cursor Daily")
end

---@param args string
function M.agent(args)
  local prompt_text = prompts.normalize_prompt(args)
  M.send_prompt(prompt_text, "Cursor Agent")
end

function M.start()
  local ok, err = pcall(config.validate)
  if not ok then
    handle_error(err, "Configuration error")
    return
  end

  local client = M.get_client()
  local cfg = config.get()

  if cfg.default_agent then
    api.find_agent(client, cfg.default_agent, function(err, agent)
      if err then
        handle_error(err, "Failed to resolve default agent")
        return
      end
      update_session(agent, nil)
      ui.show_result("Cursor Agent", ui.format_agent_status(agent, session.run))
    end)
    return
  end

  if session.agent_id then
    api.get_agent(client, session.agent_id, function(err, agent)
      if err then
        handle_error(err, "Failed to fetch current agent")
        return
      end
      update_session(agent, nil)
      ui.show_result("Cursor Agent", ui.format_agent_status(agent, session.run))
    end)
    return
  end

  ui.notify("No agent started yet. Run :CursorDaily or :CursorAgent with a prompt.", "info")
end

function M.status()
  local ok, err = pcall(config.validate)
  if not ok then
    handle_error(err, "Configuration error")
    return
  end

  local client = M.get_client()

  if not session.agent_id then
    ui.show_result("Cursor Agent Status", ui.format_agent_status(nil, nil))
    return
  end

  api.get_agent(client, session.agent_id, function(agent_err, agent)
    if agent_err then
      handle_error(agent_err, "Failed to fetch agent status")
      return
    end

    update_session(agent, nil)

    local run_id = session.run_id or agent.latestRunId
    if not run_id then
      ui.show_result("Cursor Agent Status", ui.format_agent_status(agent, nil))
      return
    end

    api.get_run(client, agent.id, run_id, function(run_err, run)
      if run_err then
        handle_error(run_err, "Failed to fetch run status")
        return
      end

      update_session(nil, run)
      ui.show_result("Cursor Agent Status", ui.format_agent_status(agent, run))
    end)
  end)
end

function M.cancel()
  if not session.agent_id or not session.run_id then
    ui.notify("No active run to cancel", "warn")
    return
  end

  local client = M.get_client()
  api.cancel_run(client, session.agent_id, session.run_id, function(err)
    if err then
      handle_error(err, "Failed to cancel run")
      return
    end
    ui.notify("Cancellation requested for run " .. session.run_id, "info")
  end)
end

function M.select_model()
  models.pick(function(selection)
    if selection == nil then
      models.set_selected(nil)
      ui.notify("Model set to Cursor default (account/team)", "info")
      return
    end

    models.set_selected(selection)
    ui.notify("Model set to " .. models.describe_selected(), "info")
  end)
end

---@param model_id string|nil
function M.set_model(model_id)
  if not model_id or model_id == "" then
    M.select_model()
    return
  end

  models.set_by_id(model_id, function(selection)
    if not selection then
      return
    end
    ui.notify("Model set to " .. models.describe_selected(), "info")
  end)
end

function M.show_models()
  models.show_catalog()
end

function M.setup_commands()
  vim.api.nvim_create_user_command("CursorDaily", function()
    M.daily()
  end, { desc = "Send the configured daily prompt to a Cursor Cloud Agent" })

  vim.api.nvim_create_user_command("CursorAgent", function(opts)
    M.agent(opts.args)
  end, {
    nargs = "+",
    desc = "Send a custom prompt to a Cursor Cloud Agent",
  })

  vim.api.nvim_create_user_command("CursorAgentStart", function()
    M.start()
  end, { desc = "Show or resolve the current Cursor Cloud Agent" })

  vim.api.nvim_create_user_command("CursorAgentStatus", function()
    M.status()
  end, { desc = "Check status of the current Cursor Cloud Agent run" })

  vim.api.nvim_create_user_command("CursorAgentCancel", function()
    M.cancel()
  end, { desc = "Cancel the active Cursor Cloud Agent run" })

  vim.api.nvim_create_user_command("CursorAgentModel", function(opts)
    M.set_model(opts.args ~= "" and opts.args or nil)
  end, {
    nargs = "?",
    complete = function()
      local cfg = config.get()
      local items = {}
      local seen = {}

      local function add(item)
        if item and item ~= "" and not seen[item] then
          seen[item] = true
          items[#items + 1] = item
        end
      end

      for _, model_id in ipairs(cfg.favorite_models or {}) do
        add(model_id)
      end

      local selected = models.get_selected()
      if selected then
        add(selected.id)
      end

      local configured = models.normalize(cfg.model)
      if configured then
        add(configured.id)
      end

      return items
    end,
    desc = "Select or set the Cursor model for new agents",
  })

  vim.api.nvim_create_user_command("CursorAgentModels", function()
    M.show_models()
  end, { desc = "List available Cursor models" })
end

return M
