return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
    keys = {
      -- Open / presets
      {
        "<leader>gvt",
        function()
          if require("diffview.lib").get_current_view() then
            vim.cmd("DiffviewClose")
          else
            vim.cmd("DiffviewOpen")
          end
        end,
        desc = "Diffview: Toggle",
      },
      { "<leader>gvo", "<cmd>DiffviewOpen<cr>", desc = "Diffview: Working Tree (Unstaged)" },
      { "<leader>gvs", "<cmd>DiffviewOpen --staged<cr>", desc = "Diffview: Staged Changes" },
      { "<leader>gvh", "<cmd>DiffviewOpen HEAD<cr>", desc = "Diffview: All Uncommitted (vs HEAD)" },
      { "<leader>gv1", "<cmd>DiffviewOpen HEAD~1<cr>", desc = "Diffview: Previous Commit (HEAD~1)" },
      { "<leader>gvm", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diffview: Branch vs Main" },
      { "<leader>gv.", "<cmd>DiffviewOpen -- %<cr>", desc = "Diffview: Current File Only" },
      { "<leader>gva", ":DiffviewOpen ", desc = "Diffview: Open with Custom Args" },

      -- File & Line History
      { "<leader>gvf", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: Current File History" },
      { "<leader>gvf", ":DiffviewFileHistory<cr>", mode = "v", desc = "Diffview: Selection History" },
      { "<leader>gvL", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: Repo History" },
      { "<leader>gvS", "<cmd>DiffviewFileHistory -g --range=stash<cr>", desc = "Diffview: Stash History" },
      { "<leader>gvA", ":DiffviewFileHistory ", desc = "Diffview: History with Custom Args" },

      -- View Controls
      { "<leader>gvc", "<cmd>DiffviewClose<cr>", desc = "Diffview: Close" },
      { "<leader>gvp", "<cmd>DiffviewToggleFiles<cr>", desc = "Diffview: Toggle Files Panel" },
      { "<leader>gvr", "<cmd>DiffviewRefresh<cr>", desc = "Diffview: Refresh" },
    },
    opts = {},
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>gv", group = "diffview" },
      },
    },
  },
}
