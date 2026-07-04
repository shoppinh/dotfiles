---@class NextjsDapOptions
---@field root? string
---@field port? number

local M = {}

local JS_FILETYPES = {
  "javascript",
  "javascriptreact",
  "javascript.jsx",
  "typescript",
  "typescriptreact",
  "typescript.tsx",
}

local FULL_STACK_LISTENER = "nextjs_fullstack_client"
local INSPECT_PORTS = { 9230, 9229, 9231 }

local PWA_ADAPTER_TYPES = {
  "pwa-node",
  "pwa-chrome",
  "pwa-msedge",
  "pwa-node-terminal",
}

---@return string
function M.get_js_debug_adapter()
  local candidates = {
    vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug-adapter",
    vim.fn.stdpath("data") .. "/mason/bin/js-debug-adapter",
    "js-debug-adapter",
  }

  for _, candidate in ipairs(candidates) do
    if vim.fn.executable(candidate) == 1 then
      return vim.fs.normalize(candidate)
    end
  end

  return candidates[1]
end

--- Patch LazyVim/typescript adapters so Mason's js-debug-adapter is used (not on PATH in GUI Neovim).
function M.patch_js_debug_adapters()
  local dap = require("dap")
  local command = M.get_js_debug_adapter()

  for _, pwa_type in ipairs(PWA_ADAPTER_TYPES) do
    local adapter = dap.adapters[pwa_type]
    if type(adapter) == "table" and adapter.executable then
      adapter.host = "127.0.0.1"
      adapter.executable.command = command
      adapter.executable.args = { "${port}", "127.0.0.1" }
    end
  end

  for _, adapter_type in ipairs({ "node", "chrome", "msedge", "node-terminal" }) do
    if not dap.adapters[adapter_type] then
      local pwa_type = adapter_type:match("^pwa%-") and adapter_type or ("pwa-" .. adapter_type)
      dap.adapters[adapter_type] = function(cb, config)
        config.type = pwa_type
        local native = dap.adapters[pwa_type]
        if type(native) == "function" then
          native(cb, config)
        else
          cb(native)
        end
      end
    end
  end
end

---@param root string
---@return boolean
function M.is_nextjs_project(root)
  if vim.uv.fs_stat(root .. "/next.config.js") then
    return true
  end
  if vim.uv.fs_stat(root .. "/next.config.mjs") then
    return true
  end
  if vim.uv.fs_stat(root .. "/next.config.ts") then
    return true
  end

  local package_json = root .. "/package.json"
  if not vim.uv.fs_stat(package_json) then
    return false
  end

  local ok, data = pcall(vim.fn.readfile, package_json)
  if not ok then
    return false
  end

  local decoded = vim.json.decode(table.concat(data, "\n"))
  local deps = vim.tbl_extend("force", decoded.dependencies or {}, decoded.devDependencies or {})
  return deps.next ~= nil
end

---@param root? string
---@return string
function M.get_root(root)
  if root then
    return vim.fs.normalize(root)
  end

  if LazyVim then
    local lazy_root = LazyVim.root.get({ "next.config.ts", "next.config.mjs", "next.config.js", "package.json" })
    if lazy_root then
      return vim.fs.normalize(lazy_root)
    end
  end

  return vim.fs.normalize(vim.fn.getcwd())
end

---@param root string
---@return string?
function M.get_node_from_launch_json(root)
  local launch_json = root .. "/.vscode/launch.json"
  if not vim.uv.fs_stat(launch_json) then
    return nil
  end

  local ok, lines = pcall(vim.fn.readfile, launch_json)
  if not ok then
    return nil
  end

  local decoded = vim.json.decode(table.concat(lines, "\n"))
  for _, config in ipairs(decoded.configurations or {}) do
    if type(config.runtimeExecutable) == "string" and config.runtimeExecutable:find("/node$") then
      if vim.fn.executable(config.runtimeExecutable) == 1 then
        return vim.fs.normalize(config.runtimeExecutable)
      end
    end
  end

  return nil
end

---@return string
function M.get_node_executable()
  local from_launch = M.get_node_from_launch_json(M.get_root())
  if from_launch then
    return from_launch
  end

  local nvm_bin = vim.env.NVM_BIN
  if nvm_bin and nvm_bin ~= "" then
    local nvm_node = vim.fs.normalize(nvm_bin .. "/node")
    if vim.fn.executable(nvm_node) == 1 then
      return nvm_node
    end
  end

  local node = vim.fn.exepath("node")
  if node and node ~= "" then
    return vim.fs.normalize(node)
  end

  return "node"
end

---@param root string
---@return string?
function M.get_package_name(root)
  local package_json = root .. "/package.json"
  if not vim.uv.fs_stat(package_json) then
    return nil
  end

  local ok, lines = pcall(vim.fn.readfile, package_json)
  if not ok then
    return nil
  end

  local decoded = vim.json.decode(table.concat(lines, "\n"))
  return decoded.name
end

---@param root string
---@return number
function M.get_dev_port(root)
  local package_json = root .. "/package.json"
  if not vim.uv.fs_stat(package_json) then
    return 3000
  end

  local ok, lines = pcall(vim.fn.readfile, package_json)
  if not ok then
    return 3000
  end

  local decoded = vim.json.decode(table.concat(lines, "\n"))
  local dev_script = decoded.scripts and decoded.scripts.dev
  if type(dev_script) ~= "string" then
    return 3000
  end

  local port = dev_script:match("%-p%s+(%d+)") or dev_script:match("%-%-port%s+(%d+)")
  return tonumber(port) or 3000
end

---@param root string
---@return string[]
function M.get_dev_args(root)
  local package_json = root .. "/package.json"
  local dev_script = "next dev"

  if vim.uv.fs_stat(package_json) then
    local ok, lines = pcall(vim.fn.readfile, package_json)
    if ok then
      local decoded = vim.json.decode(table.concat(lines, "\n"))
      if decoded.scripts and type(decoded.scripts.dev) == "string" then
        dev_script = decoded.scripts.dev
      end
    end
  end

  local tail = dev_script:match("^next%s+(.+)$") or dev_script
  local args = {}
  for token in tail:gmatch("%S+") do
    args[#args + 1] = token
  end

  if args[1] ~= "dev" then
    table.insert(args, 1, "dev")
  end

  return args
end

---@param package_name? string
---@return table<string, string>
function M.get_source_map_overrides(package_name)
  local overrides = {
    ["webpack://_N_E/*"] = "${webRoot}/*",
    ["webpack://_N_E/./**"] = "${webRoot}/**",
    ["webpack:///./*"] = "${webRoot}/*",
    ["webpack:///./~/*"] = "${webRoot}/node_modules/*",
    ["turbopack://**"] = "${webRoot}/**",
    ["turbopack:///[project]/*"] = "${webRoot}/*",
    ["/turbopack/[project]/*"] = "${webRoot}/*",
  }

  if package_name then
    overrides["webpack://" .. package_name .. "/./*"] = "${webRoot}/*"
    overrides["webpack://" .. package_name .. "/**"] = "${webRoot}/**"
  end

  return overrides
end

---@param opts? NextjsDapOptions
---@return table
function M.get_shared_server_opts(opts)
  opts = opts or {}
  local root = M.get_root(opts.root)

  return {
    cwd = root,
    sourceMaps = true,
    autoAttachChildProcesses = true,
    skipFiles = { "<node_internals>/**" },
  }
end

---@param root string
---@return table[]
function M.get_launch_json_configs(root)
  local launch_json = root .. "/.vscode/launch.json"
  if not vim.uv.fs_stat(launch_json) then
    return {}
  end

  local ok, configs = pcall(require("dap.ext.vscode").getconfigs, launch_json)
  if not ok or not configs then
    return {}
  end

  return configs
end

---@param root string
---@return table[]
function M.get_launch_json_compounds(root)
  local launch_json = root .. "/.vscode/launch.json"
  if not vim.uv.fs_stat(launch_json) then
    return {}
  end

  local ok, lines = pcall(vim.fn.readfile, launch_json)
  if not ok then
    return {}
  end

  local decoded = vim.json.decode(table.concat(lines, "\n"))
  return decoded.compounds or {}
end

---@param opts? NextjsDapOptions
---@return table
function M.get_server_config(opts)
  opts = opts or {}
  local root = M.get_root(opts.root)

  return vim.tbl_deep_extend("force", M.get_shared_server_opts({ root = root }), {
    type = "pwa-node",
    request = "launch",
    name = "Next.js: debug server",
    runtimeExecutable = M.get_node_executable(),
    program = root .. "/node_modules/next/dist/bin/next",
    args = M.get_dev_args(root),
    console = "integratedTerminal",
    env = { NODE_OPTIONS = "--inspect" },
  })
end

---@param opts? NextjsDapOptions
---@return table
function M.get_server_terminal_config(opts)
  opts = opts or {}
  local root = M.get_root(opts.root)
  local pm = "npm"
  if vim.uv.fs_stat(root .. "/pnpm-lock.yaml") then
    pm = "pnpm"
  elseif vim.uv.fs_stat(root .. "/yarn.lock") then
    pm = "yarn"
  elseif vim.uv.fs_stat(root .. "/bun.lock") or vim.uv.fs_stat(root .. "/bun.lockb") then
    pm = "bun"
  end

  local command = ({
    npm = "npm run dev",
    pnpm = "pnpm dev",
    yarn = "yarn dev",
    bun = "bun run dev",
  })[pm]

  return vim.tbl_deep_extend("force", M.get_shared_server_opts({ root = root }), {
    type = "node-terminal",
    request = "launch",
    name = "Next.js: debug server (terminal)",
    command = command,
    cwd = root,
  })
end

---@param port number
---@param opts? NextjsDapOptions
---@return table
function M.get_attach_config(port, opts)
  return vim.tbl_deep_extend("force", M.get_shared_server_opts(opts), {
    type = "pwa-node",
    request = "attach",
    name = ("Next.js: attach server (:%d)"):format(port),
    port = port,
    restart = true,
    continueOnAttach = true,
  })
end

---@param opts? NextjsDapOptions
---@return table
function M.get_client_config(opts)
  opts = opts or {}
  local root = M.get_root(opts.root)
  local port = opts.port or M.get_dev_port(root)

  return {
    type = "pwa-chrome",
    request = "launch",
    name = "Next.js: debug client",
    url = ("http://localhost:%d"):format(port),
    webRoot = root,
    sourceMaps = true,
    userDataDir = root .. "/.vscode/chrome-debug-profile",
    sourceMapPathOverrides = M.get_source_map_overrides(M.get_package_name(root)),
    skipFiles = { "<node_internals>/**", "node_modules/**" },
  }
end

---@param opts? NextjsDapOptions
---@return table[]
function M.get_fallback_configurations(opts)
  local configs = {
    M.get_server_config(opts),
    M.get_server_terminal_config(opts),
    M.get_client_config(opts),
  }

  for _, port in ipairs(INSPECT_PORTS) do
    configs[#configs + 1] = M.get_attach_config(port, opts)
  end

  configs[#configs + 1] = vim.tbl_deep_extend("force", M.get_shared_server_opts(opts), {
    type = "pwa-node",
    request = "attach",
    name = "Next.js: attach server (pick process)",
    processId = require("dap.utils").pick_process,
    restart = true,
    continueOnAttach = true,
  })

  return configs
end

---@param opts? NextjsDapOptions
---@return table[]
function M.get_picker_entries(opts)
  opts = opts or {}
  local root = M.get_root(opts.root)
  local entries = {}
  local seen = {}

  local function add(config)
    if not config.name or seen[config.name] then
      return
    end
    seen[config.name] = true
    entries[#entries + 1] = config
  end

  for _, config in ipairs(M.get_launch_json_configs(root)) do
    add(config)
  end

  for _, compound in ipairs(M.get_launch_json_compounds(root)) do
    if compound.name then
      add({
        name = compound.name,
        __compound = true,
        __compound_names = compound.configurations,
        root = root,
      })
    end
  end

  for _, config in ipairs(M.get_fallback_configurations({ root = root })) do
    add(config)
  end

  return entries
end

---@param root string
function M.prepare_workspace(root)
  root = M.get_root(root)
  if vim.fn.isdirectory(root) == 1 then
    vim.cmd("lcd " .. vim.fn.fnameescape(root))
  end
end

---@param root string
---@param compound_names string[]
function M.run_launch_compound(root, compound_names)
  local by_name = {}
  for _, config in ipairs(M.get_launch_json_configs(root)) do
    by_name[config.name] = config
  end

  local server_name = compound_names[1]
  local client_name = compound_names[2]
  local server = server_name and by_name[server_name]
  local client = client_name and by_name[client_name]

  if server and client then
    M.run_full_stack_with_configs(root, server, client)
    return
  end

  M.run_full_stack(root)
end

---@param root string
---@param server table
---@param client table
function M.run_full_stack_with_configs(root, server, client)
  local dap = require("dap")
  M.prepare_workspace(root)

  local client_started = false

  local function cleanup()
    dap.listeners.after.event_output[FULL_STACK_LISTENER] = nil
  end

  local function start_client()
    if client_started then
      return
    end
    client_started = true
    cleanup()
    vim.defer_fn(function()
      dap.run(client)
    end, 1000)
  end

  dap.listeners.after.event_output[FULL_STACK_LISTENER] = function(_, body)
    if not body or type(body.output) ~= "string" then
      return
    end
    if body.output:match("Local:%s+https?://") or body.output:lower():match("ready") then
      start_client()
    end
  end

  vim.notify("Starting server debugger. Chrome will launch when Next.js is ready.", vim.log.levels.INFO)
  dap.run(server)

  vim.defer_fn(function()
    if not client_started then
      vim.notify("Dev server is taking longer than expected. Launching Chrome debugger now.", vim.log.levels.INFO)
      start_client()
    end
  end, 15000)
end

---@param root? string
function M.run_full_stack(root)
  root = M.get_root(root)
  M.run_full_stack_with_configs(root, M.get_server_config({ root = root }), M.get_client_config({ root = root }))
end

---@param config table
---@param root string
---@return table
function M.resolve_config(config, root)
  if config.__compound then
    return config
  end

  if config.program or config.command or config.url then
    return vim.deepcopy(config)
  end

  root = M.get_root(root)

  if config.name == "Next.js: debug server" then
    return M.get_server_config({ root = root })
  end
  if config.name == "Next.js: debug server (terminal)" then
    return M.get_server_terminal_config({ root = root })
  end
  if config.name == "Next.js: debug client" then
    return M.get_client_config({ root = root })
  end
  if config.request == "attach" and config.port then
    return M.get_attach_config(config.port, { root = root })
  end
  if config.request == "attach" and config.processId then
    return vim.tbl_deep_extend("force", M.get_shared_server_opts({ root = root }), {
      type = "pwa-node",
      request = "attach",
      name = config.name,
      processId = config.processId,
      restart = true,
      continueOnAttach = true,
    })
  end

  return vim.deepcopy(config)
end

---@param config table
---@param root? string
function M.run(config, root)
  local dap = require("dap")
  root = M.get_root(root)
  M.prepare_workspace(root)

  if config.__compound then
    if config.__compound_names then
      M.run_launch_compound(root, config.__compound_names)
    else
      M.run_full_stack(root)
    end
    return
  end

  dap.run(M.resolve_config(config, root))
end

---@return string[]
function M.filetypes()
  return JS_FILETYPES
end

return M
