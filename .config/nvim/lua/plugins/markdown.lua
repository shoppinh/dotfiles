return {
  -- The lang.markdown extra enables markdownlint-cli2 (WARN diagnostics).
  -- Disable it so markdown editing / preview is not cluttered with style warnings.
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {},
        ["markdown.mdx"] = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        markdown = { "prettier", "markdown-toc" },
        ["markdown.mdx"] = { "prettier", "markdown-toc" },
      },
    },
  },

  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown", "markdown.mdx" },
    init = function()
      vim.g.mkdp_filetypes = { "markdown", "markdown.mdx" }
      vim.g.mkdp_auto_close = 1
    end,
  },
}
