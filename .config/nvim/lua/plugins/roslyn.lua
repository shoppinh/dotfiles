return {
  {
    "seblyng/roslyn.nvim",
    ft = { "cs" },
    opts = {
      -- Options passed to roslyn.nvim setup
    },
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
