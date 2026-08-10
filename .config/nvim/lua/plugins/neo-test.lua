return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "Nsidorenco/neotest-vstest",
    },
    opts = function(_, opts)
      opts = opts or {}
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

      -- 3. Retain your existing adapters (only if installed)
      if pcall(require, "neotest-vstest") then
        opts.adapters["neotest-vstest"] = {
          dap_settings = {
            type = "netcoredbg",
          },
        }
      end
      if pcall(require, "neotest-vitest") then
        opts.adapters["neotest-vitest"] = {}
      end

      -- 4. Dynamically append the initialized Jest adapter
      if pcall(require, "neotest-jest") then
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
      end
      return opts
    end,
  },
}
