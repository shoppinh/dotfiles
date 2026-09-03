local function dotnet_root()
  local dotnet = vim.fn.exepath("dotnet")
  if dotnet == "" then
    return "/usr/local/share/dotnet"
  end
  dotnet = vim.uv.fs_realpath(dotnet) or dotnet
  return vim.fn.fnamemodify(dotnet, ":h")
end

return {
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor", "cshtml" },
    init = function()
      vim.env.DOTNET_ROOT = dotnet_root()
      vim.env.DOTNET_gcServer = "0"
    end,
    opts = {
      filewatching = "roslyn",
      lock_target = true,
    },
    config = function(_, opts)
      require("roslyn").setup(opts)

      vim.lsp.config("roslyn", {
        workspace_required = true,
        settings = {
          ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "openFiles",
            dotnet_compiler_diagnostics_scope = "openFiles",
          },
          ["csharp|symbol_search"] = {
            dotnet_search_reference_assemblies = false,
          },
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "c_sharp" })
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.registries = opts.registries or { "github:mason-org/mason-registry" }
      if not vim.tbl_contains(opts.registries, "github:Crashdummyy/mason-registry") then
        table.insert(opts.registries, 1, "github:Crashdummyy/mason-registry")
      end
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "roslyn", "csharpier", "netcoredbg" })
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
      },
    },
  },
}
