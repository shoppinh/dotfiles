-- Neovim-only helpers for Next.js DAP.
-- Configurations live in the project's .vscode/launch.json (auto-loaded by nvim-dap).

local NEXT_NAMES = {
  ["Next.js: debug server"] = true,
  ["Next.js: attach server"] = true,
  ["Next.js: debug client"] = true,
}

local function find_launch_config(name)
  local ok, configs = pcall(require("dap.ext.vscode").getconfigs)
  if not ok or not configs then
    return nil
  end
  for _, config in ipairs(configs) do
    if config.name == name then
      return config
    end
  end
  return nil
end

return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")

      dap.listeners.after.event_exited["nextjs_debug_notify"] = function(session, body)
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

      vim.api.nvim_create_user_command("DapNextFullStack", function()
        local server = find_launch_config("Next.js: debug server")
        local client = find_launch_config("Next.js: debug client")
        if not server or not client then
          vim.notify("Missing Next.js configs in .vscode/launch.json", vim.log.levels.ERROR)
          return
        end
        dap.run(server)
        vim.defer_fn(function()
          dap.run(client)
        end, 6000)
      end, { desc = "Next.js full-stack debug (server + client)" })
    end,
  },
}
