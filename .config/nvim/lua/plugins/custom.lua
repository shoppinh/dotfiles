return {
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
          explorer = {
            watch = false,
          },
          notifications = {
            win = {
              input = {
                keys = {
                  ["<C-y>"] = { "yank", mode = { "i", "n" } },
                },
              },
            },
          },
        },
      },
    },
  },
  -- Neovim 0.12 removed highlighter._on_line; trouble <=3.7.1 still registers it.
  -- Pin past the on_range fix until a tagged release ships it.
  {
    "folke/trouble.nvim",
    version = false,
    commit = "bd67efe408d4816e25e8491cc5ad4088e708a69a",
    pin = true,
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
    cmd = {
      "TurboLogInsertLog",
      "TurboLogInsertInfo",
      "TurboLogInsertDebug",
      "TurboLogInsertTable",
      "TurboLogInsertWarn",
      "TurboLogInsertError",
      "TurboLogInsertCustom",
      "TurboLogCommentAll",
      "TurboLogUncommentAll",
      "TurboLogDeleteAll",
      "TurboLogCorrectAll",
      "TurboLogPanel",
      "TurboLogFind",
    },
    keys = {
      { "<D-k><D-l>", mode = { "n", "x" } },
      { "<leader>Tl", mode = { "n", "x" } },
      { "<D-k><D-i>", mode = { "n", "x" } },
      { "<leader>Ti", mode = { "n", "x" } },
      { "<D-k><D-b>", mode = { "n", "x" } },
      { "<leader>Td", mode = { "n", "x" } },
      { "<D-k><D-t>", mode = { "n", "x" } },
      { "<leader>Tt", mode = { "n", "x" } },
      { "<D-k><D-r>", mode = { "n", "x" } },
      { "<leader>Tw", mode = { "n", "x" } },
      { "<D-k><D-e>", mode = { "n", "x" } },
      { "<leader>Te", mode = { "n", "x" } },
      { "<D-k><D-k>", mode = { "n", "x" } },
      { "<leader>Tc", mode = { "n", "x" } },
      { "<A-S-c>", mode = { "n", "x" } },
      { "<leader>TC", mode = { "n", "x" } },
      { "<A-S-u>", mode = { "n", "x" } },
      { "<leader>TU", mode = { "n", "x" } },
      { "<A-S-d>", mode = { "n", "x" } },
      { "<leader>TD", mode = { "n", "x" } },
      { "<A-S-x>", mode = { "n", "x" } },
      { "<leader>TX", mode = { "n", "x" } },
      { "<D-k><D-p>", mode = { "n", "x" } },
      { "<leader>Tp", mode = { "n", "x" } },
      { "<D-k><D-f>", mode = { "n", "x" } },
      { "<leader>Tf", mode = { "n", "x" } },
    },
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
  { "akinsho/git-conflict.nvim", version = "*", event = "BufReadPre", config = true },

  {
    "mbbill/undotree",
    keys = {
      { "<leader>ou", "<cmd>UndotreeToggle<cr>", desc = "Toggle UndoTree" },
    },
  },
}
