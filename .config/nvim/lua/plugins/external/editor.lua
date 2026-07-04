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
    },
    keys = {
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
        ";r",
        function()
          Snacks.picker.grep({ hidden = true })
        end,
        desc = "Live Grep (cwd, hidden)",
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
      {
        ";e",
        function()
          Snacks.picker.diagnostics()
        end,
        desc = "Diagnostics",
      },
      {
        ";s",
        function()
          Snacks.picker.treesitter()
        end,
        desc = "Treesitter Symbols",
      },
      {
        ";c",
        function()
          Snacks.picker.lsp_incoming_calls()
        end,
        desc = "LSP Incoming Calls",
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
