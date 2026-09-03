return {
  { "nvim-telescope/telescope.nvim", enabled = false },
  { "nvim-telescope/telescope-file-browser.nvim", enabled = false },
  { "nvim-telescope/telescope-fzf-native.nvim", enabled = false },

  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        ui_select = true,
        hidden = true,
        sources = {
          files = {
            hidden = true,
          },
        },
      },
      scratch = { enabled = true },
      bufdelete = { enabled = true },
      rename = { enabled = true },
      gitbrowse = { enabled = true },
    },
    keys = {
      -- Find & Search
      {
        "<leader><leader>",
        function()
          Snacks.picker.smart()
        end,
        desc = "Smart Find Files",
      },
      {
        "<leader>fP",
        function()
          Snacks.picker.files({
            cwd = require("lazy.core.config").options.root,
            hidden = true,
          })
        end,
        desc = "Find Plugin File",
      },
      {
        "<leader>fp",
        function()
          Snacks.picker.projects()
        end,
        desc = "Projects",
      },
      {
        "<leader>fr",
        function()
          Snacks.picker.recent()
        end,
        desc = "Recent Files",
      },
      {
        ";f",
        function()
          Snacks.picker.files({
            hidden = true,
            cwd = vim.uv.cwd(),
          })
        end,
        desc = "Find Files (cwd, hidden)",
      },
      {
        "sf",
        function()
          Snacks.picker.files({
            cwd = vim.fn.expand("%:p:h"),
            hidden = true,
          })
        end,
        desc = "Find Files (buffer dir)",
      },
      {
        ";r",
        function()
          Snacks.picker.grep({ hidden = true })
        end,
        desc = "Live Grep (cwd, hidden)",
      },
      {
        ";w",
        function()
          Snacks.picker.grep_word({ hidden = true })
        end,
        desc = "Visual / Word Grep",
        mode = { "n", "x" },
      },
      {
        ";l",
        function()
          Snacks.picker.lines()
        end,
        desc = "Buffer Lines",
      },
      {
        ";b",
        function()
          Snacks.picker.grep_buffers()
        end,
        desc = "Grep Open Buffers",
      },
      {
        "\\\\",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        ";t",
        function()
          Snacks.picker.help()
        end,
        desc = "Help Tags",
      },
      {
        ";;",
        function()
          Snacks.picker.resume()
        end,
        desc = "Resume Picker",
      },

      -- Git Pickers & Remote Browse
      {
        "<leader>gs",
        function()
          Snacks.picker.git_status()
        end,
        desc = "Git Status Picker",
      },
      {
        "<leader>gl",
        function()
          Snacks.picker.git_log()
        end,
        desc = "Git Log Picker",
      },
      {
        "<leader>gL",
        function()
          Snacks.picker.git_log_file()
        end,
        desc = "Git Current File History",
      },
      {
        "<leader>gb",
        function()
          Snacks.picker.git_branches()
        end,
        desc = "Git Branches",
      },
      {
        "<leader>go",
        function()
          Snacks.gitbrowse()
        end,
        desc = "Open in Remote Browser (GitHub/GitLab)",
        mode = { "n", "x" },
      },

      -- LSP & Code Navigation
      {
        "gd",
        function()
          Snacks.picker.lsp_definitions()
        end,
        desc = "LSP Goto Definition",
      },
      {
        "gr",
        function()
          Snacks.picker.lsp_references()
        end,
        nowait = true,
        desc = "LSP References",
      },
      {
        ";s",
        function()
          Snacks.picker.lsp_symbols()
        end,
        desc = "LSP Document Symbols",
      },
      {
        ";S",
        function()
          Snacks.picker.lsp_workspace_symbols()
        end,
        desc = "LSP Workspace Symbols",
      },
      {
        ";e",
        function()
          Snacks.picker.diagnostics()
        end,
        desc = "Diagnostics",
      },
      {
        ";c",
        function()
          Snacks.picker.lsp_incoming_calls()
        end,
        desc = "LSP Incoming Calls",
      },
      {
        "<leader>cR",
        function()
          Snacks.rename.rename_file()
        end,
        desc = "Rename File (update imports)",
      },

      -- Productivity & Utilities
      {
        "<leader>u",
        function()
          Snacks.picker.undo()
        end,
        desc = "Undo Tree",
      },
      {
        "<leader>.",
        function()
          Snacks.scratch()
        end,
        desc = "Toggle Scratchpad",
      },
      {
        "<leader>S",
        function()
          Snacks.scratch.select()
        end,
        desc = "Select Scratchpad",
      },
      {
        "<leader>bd",
        function()
          Snacks.bufdelete()
        end,
        desc = "Delete Buffer (preserve layout)",
      },
      {
        "<leader>un",
        function()
          Snacks.picker.notifications()
        end,
        desc = "Notification History",
      },
    },
  },

  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = {
          winblend = vim.o.pumblend,
        },
      },
      signature = {
        window = {
          winblend = vim.o.pumblend,
        },
      },
    },
  },
}
