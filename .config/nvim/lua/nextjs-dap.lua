-- Next.js entries from .vscode/launch.json for the normal DAP continue picker.
-- nvim-dap's built-in launch.json provider returns configurations only, so
-- compounds never appear, and it offers every configuration for every filetype.

local M = {}

M.COMPOUND_STEP_MS = 6000
M.JS_FILETYPES = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

local NEXT_NAMES = {
  ["Next.js: debug server"] = true,
  ["Next.js: attach server"] = true,
  ["Next.js: debug client"] = true,
  ["Next.js: debug"] = true,
  ["Next.js: full stack"] = true,
  ["Next.js: debug full stack"] = true,
  ["_next: dev server"] = true,
  ["_next: attach router"] = true,
  ["_next: chrome"] = true,
}

function M.is_next_config(config)
  return type(config) == "table" and NEXT_NAMES[config.name] == true
end

function M.launch_json_path(cwd)
  local path = (cwd or vim.fn.getcwd()) .. "/.vscode/launch.json"
  if vim.uv.fs_stat(path) then
    return path
  end
  return nil
end

local function decode_launch(path)
  local lines = {}
  for line in io.lines(path) do
    if not vim.startswith(vim.trim(line), "//") then
      table.insert(lines, line)
    end
  end
  local ok, data = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok or type(data) ~= "table" then
    return nil
  end
  return data
end

function M.next_configs(cwd)
  local path = M.launch_json_path(cwd)
  if not path then
    return {}
  end
  local ok, configs = pcall(require("dap.ext.vscode").getconfigs, path)
  if not ok or type(configs) ~= "table" then
    return {}
  end
  local next_configs = {}
  for _, config in ipairs(configs) do
    if M.is_next_config(config) then
      next_configs[#next_configs + 1] = config
    end
  end
  return next_configs
end

function M.menu_items(cwd)
  local path = M.launch_json_path(cwd)
  local items = {}
  local seen = {}
  for _, config in ipairs(M.next_configs(cwd)) do
    if config.name and not seen[config.name] then
      seen[config.name] = true
      items[#items + 1] = config
    end
  end

  local data = path and decode_launch(path) or nil
  for _, compound in ipairs((data and data.compounds) or {}) do
    if M.is_next_config(compound) and compound.name and not seen[compound.name] then
      seen[compound.name] = true
      items[#items + 1] = {
        name = compound.name,
        type = "nextjs-compound",
        request = "launch",
        configurations = compound.configurations or {},
        stopAll = compound.stopAll,
      }
    end
  end

  if seen["Next.js: debug server"] and seen["Next.js: debug client"] and not seen["Next.js: full stack"] then
    items[#items + 1] = {
      name = "Next.js: full stack",
      type = "nextjs-compound",
      request = "launch",
      configurations = { "Next.js: debug server", "Next.js: debug client" },
    }
  end

  return items
end

local function find_named(items, name)
  for _, item in ipairs(items) do
    if item.name == name then
      return item
    end
  end
end

-- VS Code's node-terminal type asks js-debug to open a terminal and run `command`.
-- nvim-dap has no adapter by that name. pwa-node is the js-debug server LazyVim
-- already registers, and it launches the same command in an integrated terminal.
function M.prepare(config)
  if type(config) ~= "table" or config.type ~= "node-terminal" then
    return config
  end
  local prepared = vim.deepcopy(config)
  prepared.type = "pwa-node"
  prepared.request = "launch"
  prepared.console = prepared.console or "integratedTerminal"
  if prepared.command and not prepared.runtimeArgs then
    prepared.runtimeExecutable = "bash"
    prepared.runtimeArgs = { "-lc", prepared.command }
    prepared.command = nil
  end
  return prepared
end

function M.run_item(dap, item, items, step_ms, cwd)
  items = items or M.menu_items(cwd)
  if item.type == "nextjs-compound" then
    local step = step_ms or M.COMPOUND_STEP_MS
    local delay = 0
    local missing = {}
    for _, name in ipairs(item.configurations or {}) do
      local config = find_named(items, name)
      if config and config.type ~= "nextjs-compound" then
        local prepared = M.prepare(config)
        if delay == 0 then
          dap.run(prepared)
        else
          vim.defer_fn(function()
            dap.run(prepared)
          end, delay)
        end
        delay = delay + step
      else
        missing[#missing + 1] = name
      end
    end
    if #missing > 0 then
      vim.notify("Missing Next.js configs: " .. table.concat(missing, ", "), vim.log.levels.ERROR)
    end
    return
  end
  dap.run(M.prepare(item))
end

-- dap.continue() keeps a local reference to dap.run, so wrapping that export
-- never sees the selection. The picker launches by config.type. This adapter
-- starts the compound's real sessions, then resolves a non-launchable adapter
-- so nvim-dap stops before opening a synthetic nextjs-compound session.
-- The continue picker calls the original dap.run. Give each compound a
-- metatable so that call expands it into the real launch.json sessions
-- before nvim-dap looks up an adapter.
function M.as_runnable(item, items, cwd)
  if item.type ~= "nextjs-compound" then
    return item
  end
  return setmetatable(item, {
    __call = function()
      local dap = require("dap")
      M.run_item(dap, item, items, 0, cwd)
      -- prepare_config treats ABORT as a signal to stop before adapter lookup.
      return { type = dap.ABORT }
    end,
  })
end

function M.provider_configs(cwd)
  local items = M.menu_items(cwd)
  local runnable = {}
  for _, item in ipairs(items) do
    runnable[#runnable + 1] = M.as_runnable(item, items, cwd)
  end
  return runnable
end

function M.install(dap)
  dap.providers.configs["nextjs-dap"] = function()
    return M.provider_configs()
  end
end

function M.start_full_stack(cwd)
  local dap = require("dap")
  local items = M.menu_items(cwd)
  local server = find_named(items, "Next.js: debug server") or find_named(items, "_next: dev server")
  local client = find_named(items, "Next.js: debug client") or find_named(items, "_next: chrome")
  if not server or not client then
    vim.notify("Missing Next.js configs in .vscode/launch.json", vim.log.levels.ERROR)
    return
  end
  M.run_item(dap, {
    type = "nextjs-compound",
    configurations = { server.name, client.name },
  }, items)
end

function M.register_launch_types()
  local ok, vscode = pcall(require, "dap.ext.vscode")
  if not ok then
    return
  end
  for _, adapter_type in ipairs({ "node", "pwa-node", "chrome", "pwa-chrome", "node-terminal" }) do
    vscode.type_to_filetypes[adapter_type] = M.JS_FILETYPES
  end
end

function M.on_exited(session, body)
  local name = session.config and session.config.name
  if not name or not NEXT_NAMES[name] then
    return
  end
  if body.exitCode and body.exitCode ~= 0 then
    vim.notify(
      ("[%s] exited with code %s. Stop any running `next dev` and retry."):format(name, body.exitCode),
      vim.log.levels.ERROR
    )
  end
end

return M
