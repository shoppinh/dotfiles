return {
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gdiffsplit", "Gread", "Gwrite" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git Status" },
      { "gu", "<cmd>diffget //2<cr>", mode = "n", desc = "Git Diff: Get Target (Left)" },
      { "gh", "<cmd>diffget //3<cr>", mode = "n", desc = "Git Diff: Get Merge (Right)" },
    },
  },
}
