-- Python DAP: launch.json (type "debugpy") + nvim-dap-python defaults.
-- Requires: lazyvim.plugins.extras.lang.python + mason package debugpy

return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      ensure_installed = { "debugpy" },
    },
  },

  {
    "mfussenegger/nvim-dap",
    opts = function()
      local vscode = require("dap.ext.vscode")
      vscode.type_to_filetypes["debugpy"] = { "python" }
    end,
  },
}
