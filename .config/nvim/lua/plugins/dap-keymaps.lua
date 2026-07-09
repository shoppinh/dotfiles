-- VS Code-style debug keymaps — using Option (Alt) instead of Fn keys
-- Fn keys are unreliable on this keyboard; kitty is configured with
-- `macos_option_as_alt left`, so left-Option sends real <M-*> escape
-- sequences that Neovim receives correctly.
--
-- Mnemonic map:
--   <M-c>  Continue / Start       (c = continue)
--   <M-q>  Stop / Terminate       (q = quit)
--   <M-r>  Restart                (r = restart)
--   <M-p>  Pause                  (p = pause)
--   <M-b>  Toggle Breakpoint      (b = breakpoint)
--   <M-n>  Step Over              (n = next / over)
--   <M-i>  Step Into              (i = into)
--   <M-o>  Step Out               (o = out)
--
-- <leader>d* bindings are still available via lazyvim.plugins.extras.dap.core

return {
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    config = function()
      local dap = require("dap")
      local map = function(key, fn, desc)
        vim.keymap.set("n", key, fn, { desc = desc, silent = true })
      end

      -- Option+C — Start / Continue  (was F5)
      map("<M-c>", function() dap.continue() end, "Debug: Start/Continue")
      -- Option+Q — Stop              (was Shift+F5)
      map("<M-q>", function() dap.terminate() end, "Debug: Stop")
      -- Option+R — Restart           (was Ctrl/Cmd+Shift+F5)
      map("<M-r>", function() dap.restart() end, "Debug: Restart")

      -- Option+P — Pause             (was F6)
      map("<M-p>", function() dap.pause() end, "Debug: Pause")

      -- Option+B — Toggle Breakpoint (was F9)
      map("<M-b>", function() dap.toggle_breakpoint() end, "Debug: Toggle Breakpoint")

      -- Option+N — Step Over         (was F10)
      map("<M-n>", function() dap.step_over() end, "Debug: Step Over")
      -- Option+I — Step Into         (was F11)
      map("<M-i>", function() dap.step_into() end, "Debug: Step Into")
      -- Option+O — Step Out          (was Shift+F11)
      map("<M-o>", function() dap.step_out() end, "Debug: Step Out")
    end,
  },
}
