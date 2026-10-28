return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "dracula",
    },
  },
  {
    "ellisonleao/gruvbox.nvim",
    lazy = true,
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
  },
  {
    "sainnhe/everforest",
    lazy = true,
  },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = true,
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = true,
  },
  {
    "olimorris/onedarkpro.nvim",
    lazy = true,
  },
  {
    "savq/melange-nvim",
    lazy = true,
  },
  {
    "rose-pine/neovim",
    lazy = true,
  },
  {
    "projekt0n/github-nvim-theme",
    lazy = true,
  },
  {
    "eldritch-theme/eldritch.nvim",
    lazy = true,
  },
  {
    "bluz71/vim-nightfly-colors",
    lazy = true,
  },
  { "savq/melange-nvim", lazy = true },
  { "AlexvZyl/nordic.nvim", lazy = true },
  {
    "zenbones-theme/zenbones.nvim",
    lazy = true,
  },
  {
    "jacoborus/tender.vim",
    lazy = true,
  },
  {
    "bluz71/vim-moonfly-colors",
    lazy = true,
  },
  {
    "nyoom-engineering/oxocarbon.nvim",
    lazy = true,
  },
  {
    "rktjmp/lush.nvim",
    lazy = true,
  },
  {
    "Mofiqul/vscode.nvim",
    lazy = true,
  },
  {
    "Mofiqul/dracula.nvim",
    lazy = true,
  },
  {
    "marko-cerovac/material.nvim",
    lazy = true,
  },
  { "craftzdog/solarized-osaka.nvim", lazy = true },
  {
    "sainnhe/sonokai",
    lazy = true,
  },
  {
    "tiagovla/tokyodark.nvim",
    lazy = true,
  },
  {
    "D0nw0r/dark2026.nvim",
    lazy = true,
  },
  {
    "tanvirtin/monokai.nvim",
    lazy = true,
    init = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("monokai_contrast", { clear = true }),
        pattern = "monokai*",
        callback = function()
          vim.api.nvim_set_hl(0, "Visual", { bg = "#415980" })
          vim.api.nvim_set_hl(0, "VisualNOS", { bg = "#374b6b" })
          vim.api.nvim_set_hl(0, "CursorLine", { bg = "#3b404c" })
          vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#fd971f", bg = "#3b404c", bold = true })
        end,
      })
    end,
  },
  {
    "ayu-theme/ayu-vim",
    lazy = true,
  },
}
