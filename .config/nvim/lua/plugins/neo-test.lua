return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-jest",
    },
    opts = function(_, opts)
      -- 1. Retain your static configurations
      opts.status = { virtual_text = true }
      opts.output = { open_on_run = true }
      opts.floating = {
        border = "rounded",
        max_height = 0.8,
        max_width = 0.9,
      }

      -- 2. Ensure adapters table exists
      opts.adapters = opts.adapters or {}

      -- 3. Retain your existing adapters
      opts.adapters["neotest-vstest"] = {
        dap_settings = {
          type = "netcoredbg",
        },
      }
      opts.adapters["neotest-vitest"] = {}

      -- 4. Dynamically append the initialized Jest adapter
      table.insert(
        opts.adapters,
        require("neotest-jest")({
          jestCommand = "npm test --",
          jestConfigFile = function(file)
            if file:find("apps/app-one") then
              return "apps/app-one/jest.config.js"
            end
            return "jest.config.js"
          end,
          env = { CI = true },
          cwd = function(path)
            return vim.fn.getcwd()
          end,
        })
      )
    end,
  },
}
