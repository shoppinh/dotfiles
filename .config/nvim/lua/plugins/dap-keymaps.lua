-- VS Code default debug keys (https://code.visualstudio.com/docs/debugtest/debugging)
-- <leader>d* still available via lazyvim.plugins.extras.dap.core

return {
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    config = function()
      local dap = require("dap")
      local map = function(key, fn, desc)
        vim.keymap.set("n", key, fn, { desc = desc, silent = true })
      end

      -- F5 — Start / Continue
      map("<F5>", function() dap.continue() end, "Debug: Start/Continue")
      -- Shift+F5 — Stop
      map("<S-F5>", function() dap.terminate() end, "Debug: Stop")
      -- Ctrl+Shift+F5 — Restart (VS Code Windows/Linux; also Cmd+Shift+F5 on macOS)
      map("<C-S-F5>", function() dap.restart() end, "Debug: Restart")
      map("<D-S-F5>", function() dap.restart() end, "Debug: Restart")

      -- F6 — Pause
      map("<F6>", function() dap.pause() end, "Debug: Pause")

      -- F9 — Toggle Breakpoint
      map("<F9>", function() dap.toggle_breakpoint() end, "Debug: Toggle Breakpoint")

      -- F10 — Step Over
      map("<F10>", function() dap.step_over() end, "Debug: Step Over")
      -- F11 — Step Into
      map("<F11>", function() dap.step_into() end, "Debug: Step Into")
      -- Shift+F11 — Step Out
      map("<S-F11>", function() dap.step_out() end, "Debug: Step Out")
    end,
  },
}
