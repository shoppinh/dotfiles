local nextjs = require("config.nextjs-dap")

local function setup_nextjs_dap()
  local dap = require("dap")
  local vscode = require("dap.ext.vscode")
  local js_filetypes = nextjs.filetypes()

  nextjs.patch_js_debug_adapters()

  vscode.type_to_filetypes.node = js_filetypes
  vscode.type_to_filetypes.chrome = js_filetypes
  vscode.type_to_filetypes["node-terminal"] = js_filetypes
  vscode.type_to_filetypes["pwa-node"] = js_filetypes
  vscode.type_to_filetypes["pwa-chrome"] = js_filetypes
  vscode.type_to_filetypes["pwa-node-terminal"] = js_filetypes

  -- Use LazyVim project root for launch.json (not whatever cwd Neovim started in).
  dap.providers.configs["dap.launch.json"] = function()
    local root = nextjs.get_root()
    if nextjs.is_nextjs_project(root) then
      nextjs.prepare_workspace(root)
      local configs = nextjs.get_launch_json_configs(root)
      if #configs > 0 then
        return configs
      end
    end
    return vscode.getconfigs()
  end

  local adapter = nextjs.get_js_debug_adapter()
  if vim.fn.executable(adapter) ~= 1 then
    vim.notify("js-debug-adapter not found. Run :MasonInstall js-debug-adapter", vim.log.levels.ERROR)
  end
end

return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "mason-org/mason.nvim",
        optional = true,
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          vim.list_extend(opts.ensure_installed, { "js-debug-adapter" })
        end,
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        once = true,
        callback = setup_nextjs_dap,
      })
    end,
    config = function()
      setup_nextjs_dap()
    end,
    keys = {
      {
        "<leader>dn",
        function()
          local root = nextjs.get_root()

          if not nextjs.is_nextjs_project(root) then
            vim.notify("Not in a Next.js project: " .. root, vim.log.levels.WARN)
            return
          end

          local configs = nextjs.get_picker_entries({ root = root })
          if #configs == 0 then
            vim.notify("No Next.js debug configurations found", vim.log.levels.WARN)
            return
          end

          if #configs == 1 then
            nextjs.run(configs[1], root)
            return
          end

          require("dap.ui").pick_if_many(
            configs,
            "Next.js debug: ",
            function(config)
              return config.name
            end,
            function(choice)
              if choice then
                nextjs.run(choice, root)
              end
            end
          )
        end,
        desc = "Debug Next.js",
      },
    },
  },
}
