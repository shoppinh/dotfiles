local config = require("cursor-agent.config")

local M = {}

local state = {
  float_win = nil,
  float_buf = nil,
  split_buf = nil,
  split_win = nil,
}

---@param title string
---@param content string
---@param opts? table
function M.show_float(title, content, opts)
  opts = vim.tbl_deep_extend("force", config.get().ui or {}, opts or {})

  if state.float_win and vim.api.nvim_win_is_valid(state.float_win) then
    vim.api.nvim_win_close(state.float_win, true)
  end

  if state.float_buf and vim.api.nvim_buf_is_valid(state.float_buf) then
    vim.api.nvim_buf_delete(state.float_buf, { force = true })
  end

  local width = math.floor(vim.o.columns * (opts.width or 0.8))
  local height = math.floor(vim.o.lines * (opts.height or 0.8))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  state.float_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(state.float_buf, "cursor-agent://" .. title)
  vim.api.nvim_buf_set_option(state.float_buf, "filetype", "markdown")
  vim.api.nvim_buf_set_option(state.float_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_lines(state.float_buf, 0, -1, false, vim.split(content, "\n", { plain = true }))

  state.float_win = vim.api.nvim_open_win(state.float_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = opts.border or "rounded",
    title = title,
    title_pos = "center",
  })

  vim.keymap.set("n", "q", function()
    if state.float_win and vim.api.nvim_win_is_valid(state.float_win) then
      vim.api.nvim_win_close(state.float_win, true)
    end
  end, { buffer = state.float_buf, silent = true, desc = "Close cursor-agent window" })
end

---@param title string
---@param content string
function M.show_split(title, content)
  if state.split_buf and vim.api.nvim_buf_is_valid(state.split_buf) then
    vim.api.nvim_buf_delete(state.split_buf, { force = true })
  end

  vim.cmd("botright vsplit")
  state.split_win = vim.api.nvim_get_current_win()
  state.split_buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_win_set_buf(state.split_win, state.split_buf)
  vim.api.nvim_buf_set_name(state.split_buf, "cursor-agent://" .. title)
  vim.api.nvim_buf_set_option(state.split_buf, "filetype", "markdown")
  vim.api.nvim_buf_set_option(state.split_buf, "bufhidden", "hide")
  vim.api.nvim_buf_set_lines(state.split_buf, 0, -1, false, vim.split(content, "\n", { plain = true }))
end

---@param title string
---@param content string
function M.show_quickfix(title, content)
  local qf_items = {}
  for idx, line in ipairs(vim.split(content, "\n", { plain = true })) do
    qf_items[#qf_items + 1] = {
      bufnr = 0,
      lnum = idx,
      col = 1,
      text = line,
    }
  end

  vim.fn.setqflist(qf_items, "r")
  vim.cmd("copen")
  vim.notify("[cursor-agent] " .. title .. " added to quickfix list", vim.log.levels.INFO)
end

---@param title string
---@param content string
---@param opts? table
function M.show_result(title, content, opts)
  local ui = vim.tbl_deep_extend("force", config.get().ui or {}, opts or {})
  local display = ui.display or "float"

  if display == "split" then
    M.show_split(title, content)
  elseif display == "quickfix" then
    M.show_quickfix(title, content)
  else
    M.show_float(title, content, ui)
  end
end

---@param message string
---@param level? string
function M.notify(message, level)
  vim.notify("[cursor-agent] " .. message, vim.log.levels[(level or "info"):upper()] or vim.log.levels.INFO)
end

---@param message string
function M.notify_progress(message)
  M.notify(message, "info")
end

---@param prompt string
---@param entries table[]
---@param format_item fun(entry: table): string
---@param on_select fun(entry: table|nil)
function M.select_from_list(prompt, entries, format_item, on_select)
  vim.ui.select(entries, {
    prompt = prompt,
    format_item = format_item,
  }, function(choice)
    on_select(choice)
  end)
end

---@param run table|nil
---@return string
function M.format_run_status(run)
  if not run then
    return "No active run"
  end

  local lines = {
    "# Cursor Agent Run",
    "",
    string.format("- **Status:** %s", run.status or "unknown"),
    string.format("- **Run ID:** %s", run.id or "n/a"),
    string.format("- **Agent ID:** %s", run.agentId or "n/a"),
  }

  if run.durationMs then
    lines[#lines + 1] = string.format("- **Duration:** %d ms", run.durationMs)
  end

  if run.result then
    lines[#lines + 1] = ""
    lines[#lines + 1] = "## Result"
    lines[#lines + 1] = run.result
  end

  if run.git and run.git.branches then
    lines[#lines + 1] = ""
    lines[#lines + 1] = "## Git"
    for _, branch in ipairs(run.git.branches) do
      local detail = string.format("%s (%s)", branch.branch or "unknown", branch.repoUrl or "")
      if branch.prUrl then
        detail = detail .. " — PR: " .. branch.prUrl
      end
      lines[#lines + 1] = "- " .. detail
    end
  end

  return table.concat(lines, "\n")
end

---@param agent table|nil
---@param run table|nil
---@return string
function M.format_agent_status(agent, run)
  local lines = {
    "# Cursor Agent Status",
    "",
  }

  local models = require("cursor-agent.models")
  lines[#lines + 1] = string.format("- **Model:** %s", models.describe_selected())

  if agent then
    lines[#lines + 1] = string.format("- **Agent:** %s", agent.name or agent.id or "unknown")
    lines[#lines + 1] = string.format("- **Agent ID:** %s", agent.id or "n/a")
    lines[#lines + 1] = string.format("- **Agent Status:** %s", agent.status or "unknown")
    if agent.url then
      lines[#lines + 1] = string.format("- **URL:** %s", agent.url)
    end
  else
    lines[#lines + 1] = "- **Agent:** none"
  end

  if run then
    lines[#lines + 1] = ""
    lines[#lines + 1] = M.format_run_status(run)
  end

  return table.concat(lines, "\n")
end

return M
