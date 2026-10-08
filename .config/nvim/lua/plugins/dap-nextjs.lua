-- Next.js DAP menu for the normal continue flow (<leader>dc / dap.continue).
-- Configurations live in the project's .vscode/launch.json.

return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local nextjs = require("nextjs-dap")
      nextjs.register_launch_types()

      local dap = require("dap")
      nextjs.install(dap)

      dap.listeners.after.event_exited["nextjs_debug_notify"] = nextjs.on_exited

      vim.api.nvim_create_user_command("DapNext", function()
        local items = nextjs.menu_items()
        if #items == 0 then
          vim.notify("No Next.js configs in .vscode/launch.json", vim.log.levels.ERROR)
          return
        end
        vim.ui.select(items, {
          prompt = "Next.js debug: ",
          format_item = function(item)
            return item.name
          end,
        }, function(item)
          if item then
            nextjs.run_item(dap, item, items)
          end
        end)
      end, { desc = "Next.js debug menu" })

      vim.api.nvim_create_user_command("DapNextFullStack", function()
        nextjs.start_full_stack()
      end, { desc = "Next.js full-stack debug (server + client)" })
    end,
  },
}
