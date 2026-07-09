-- Mac Option (Alt) DAP layer — no leader chords, no F-keys.
-- Avoids Option+hjkl (kitty split nav). Option+j is also kitty-bound; use Option+c for continue.

return {
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    config = function()
      local dap = require("dap")
      local map = function(key, fn, desc)
        vim.keymap.set("n", key, fn, { desc = desc, silent = true })
      end

      map("<A-c>", function() dap.continue() end, "Debug: Continue")
      map("<A-n>", function() dap.step_over() end, "Debug: Step Over")
      map("<A-i>", function() dap.step_into() end, "Debug: Step Into")
      map("<A-o>", function() dap.step_out() end, "Debug: Step Out")
      map("<A-b>", function() dap.toggle_breakpoint() end, "Debug: Breakpoint")
      map("<A-t>", function() dap.terminate() end, "Debug: Terminate")
      map("<A-p>", function() dap.pause() end, "Debug: Pause")
      map("<A-m>", function() dap.run_to_cursor() end, "Debug: Run to Cursor")
    end,
  },
}
