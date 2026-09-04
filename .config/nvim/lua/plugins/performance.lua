local function very_lazy()
  return { "VeryLazy" }
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      folds = { enable = false },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = very_lazy,
    opts = {
      current_line_blame = false,
    },
  },
  { "nvim-treesitter/nvim-treesitter-context", event = very_lazy },
  { "gbprod/yanky.nvim", event = very_lazy },
  { "folke/todo-comments.nvim", event = very_lazy },
  { "nvim-mini/mini.hipatterns", event = very_lazy },
  {
    "windwp/nvim-ts-autotag",
    event = function()
      return {}
    end,
    ft = {
      "astro",
      "blade",
      "dot",
      "elixir",
      "eruby",
      "glimmer",
      "handlebars",
      "hbs",
      "heex",
      "html",
      "htmlangular",
      "htmldjango",
      "javascript",
      "javascript.glimmer",
      "javascript.jsx",
      "javascriptreact",
      "liquid",
      "markdown",
      "php",
      "rescript",
      "rust",
      "svelte",
      "templ",
      "twig",
      "typescript",
      "typescript.glimmer",
      "typescript.tsx",
      "typescriptreact",
      "vento",
      "vue",
      "xml",
    },
  },
}
