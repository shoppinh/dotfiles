return {
  {
    "eandrju/cellular-automaton.nvim",
  },
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
  },
  {
    "mikavilpas/yazi.nvim",
    dependencies = { "folke/snacks.nvim" },
    keys = {
      { "<leader>-", "<cmd>Yazi<cr>", desc = "Open Yazi (cwd)" },
      { "<leader>_", "<cmd>Yazi cwd<cr>", desc = "Open Yazi (file dir)" },
      { "<C-up>", "<cmd>Yazi toggle<cr>", desc = "Toggle Yazi" },
    },
    opts = {
      open_for_directories = true,
      keymaps = { show_help = "<f1>" },
    },
  },
  {
    "kienmac2k/turbo-log.nvim",
    dir = vim.fn.stdpath("config") .. "/lua/turbo-log.nvim",
    main = "turbo-log",
    dependencies = { "folke/trouble.nvim" },
    config = true,
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>o", group = "own" },
      },
    },
  },
  { "akinsho/git-conflict.nvim", version = "*", config = true },

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
    },
  },
}
