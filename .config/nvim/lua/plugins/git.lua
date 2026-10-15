local function diffview_line_commit()
  local bufnr = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    vim.notify("No file associated with the current buffer", vim.log.levels.WARN)
    return
  end

  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local commit = nil
  local git_root = nil

  -- 1. Try to read commit from GitSigns current line blame cache
  local blame_dict = vim.b[bufnr].gitsigns_blame_line_dict
  if blame_dict and (blame_dict.final_lnum == lnum or blame_dict.orig_lnum == lnum or blame_dict.lnum == lnum) then
    commit = blame_dict.sha
  end

  -- Determine git root from GitSigns if available
  local bstatus = vim.b[bufnr].gitsigns_status_dict
  if bstatus and bstatus.root and bstatus.root ~= "" then
    git_root = bstatus.root
  end

  -- 2. If no commit found from inlay/cache, run git blame for the current line
  if not commit or commit:match("^0+$") then
    local check_dirs = {}
    if git_root then
      table.insert(check_dirs, git_root)
    end
    table.insert(check_dirs, vim.fn.getcwd())
    local file_dir = vim.fs.dirname(file)
    table.insert(check_dirs, file_dir)
    local detected_root = vim.fs.root(file, ".git")
    if detected_root then
      table.insert(check_dirs, detected_root)
    end

    for _, dir in ipairs(check_dirs) do
      local res = vim.system(
        { "git", "-C", dir, "blame", "-L", string.format("%d,%d", lnum, lnum), "--porcelain", "--", file },
        { text = true }
      ):wait()
      if res.code == 0 and res.stdout and res.stdout ~= "" then
        local found = res.stdout:match("^(%x+)")
        if found then
          commit = found
          git_root = dir
          break
        end
      end
    end
  end

  if not commit or commit:match("^0+$") then
    vim.notify("Current line has uncommitted changes (not committed yet)", vim.log.levels.INFO)
    return
  end

  -- Open Diffview for this specific commit
  local cmd = string.format("DiffviewOpen %s^!", commit)
  if git_root then
    cmd = cmd .. string.format(" -C%s", vim.fn.fnameescape(git_root))
  end
  cmd = cmd .. string.format(" --selected-file=%s", vim.fn.fnameescape(file))

  vim.cmd(cmd)
end

local function gitsigns_menu()
  local ok, gitsigns = pcall(require, "gitsigns")
  if not ok then
    vim.notify("gitsigns could not be loaded", vim.log.levels.WARN)
    return
  end

  local actions = {
    { label = "Diffview: Line's Commit Changes", action = diffview_line_commit },
    { label = "Preview Hunk (Popup)", action = function() gitsigns.preview_hunk() end },
    { label = "Preview Hunk (Inline)", action = function() gitsigns.preview_hunk_inline() end },
    { label = "Stage Hunk", action = function() gitsigns.stage_hunk() end },
    { label = "Reset Hunk (Discard)", action = function() gitsigns.reset_hunk() end },
    { label = "Undo Stage Hunk", action = function() gitsigns.undo_stage_hunk() end },
    { label = "Stage Entire Buffer", action = function() gitsigns.stage_buffer() end },
    { label = "Reset Entire Buffer", action = function() gitsigns.reset_buffer() end },
    { label = "Blame Current Line (Full Popup)", action = function() gitsigns.blame_line({ full = true }) end },
    { label = "Blame Entire Buffer", action = function() gitsigns.blame() end },
    { label = "Toggle Current Line Blame (Inline)", action = function() gitsigns.toggle_current_line_blame() end },
    { label = "Toggle Deleted Lines", action = function() gitsigns.toggle_deleted() end },
    { label = "Diff This (vs Index)", action = function() gitsigns.diffthis() end },
    { label = "Diff This (vs HEAD~1)", action = function() gitsigns.diffthis("~") end },
    { label = "Next Hunk", action = function() gitsigns.nav_hunk("next") end },
    { label = "Prev Hunk", action = function() gitsigns.nav_hunk("prev") end },
    { label = "Quickfix List: All Hunks", action = function() gitsigns.setqflist("all") end },
  }

  vim.ui.select(actions, {
    prompt = "GitSigns Actions",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if choice then
      choice.action()
    end
  end)
end

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
      "DiffviewLineCommit",
    },
    init = function()
      vim.api.nvim_create_user_command("DiffviewLineCommit", diffview_line_commit, { desc = "Diffview: View current line commit changes" })
    end,
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
      { "<leader>gvb", "<cmd>DiffviewFileHistory --base=LOCAL %<cr>", desc = "Diffview: File History (Base: Local)" },
      { "<leader>gvb", ":DiffviewFileHistory --base=LOCAL<cr>", mode = "v", desc = "Diffview: Selection History (Base: Local)" },
      { "<leader>gvl", diffview_line_commit, desc = "Diffview: Current Line's Commit" },
      { "<leader>gvL", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: Repo History" },
      { "<leader>gvS", "<cmd>DiffviewFileHistory -g --range=stash<cr>", desc = "Diffview: Stash History" },
      { "<leader>gvA", ":DiffviewFileHistory ", desc = "Diffview: History with Custom Args" },

      -- View Controls
      { "<leader>gvq", "<cmd>DiffviewClose<cr>", desc = "Diffview: Close" },
      { "<leader>gvp", "<cmd>DiffviewToggleFiles<cr>", desc = "Diffview: Toggle Files Panel" },
      { "<leader>gvr", "<cmd>DiffviewRefresh<cr>", desc = "Diffview: Refresh" },
    },
    opts = {},
  },
  {
    "lewis6991/gitsigns.nvim",
    cmd = { "Gitsigns", "GitsignsMenu" },
    init = function()
      vim.api.nvim_create_user_command("GitsignsMenu", gitsigns_menu, { desc = "GitSigns: Popular commands menu" })
    end,
    keys = {
      { "<leader>gm", gitsigns_menu, desc = "GitSigns: Actions Menu" },
      { "<leader>ghm", gitsigns_menu, desc = "GitSigns: Actions Menu" },
      { "<leader>ghl", diffview_line_commit, desc = "GitSigns: View Line's Commit in Diffview" },
      { "<leader>ghs", "<cmd>Gitsigns stage_hunk<cr>", mode = { "n", "v" }, desc = "GitSigns: Stage Hunk" },
      { "<leader>ghr", "<cmd>Gitsigns reset_hunk<cr>", mode = { "n", "v" }, desc = "GitSigns: Reset Hunk" },
      { "<leader>ghu", "<cmd>Gitsigns undo_stage_hunk<cr>", desc = "GitSigns: Undo Stage Hunk" },
      { "<leader>ghp", "<cmd>Gitsigns preview_hunk<cr>", desc = "GitSigns: Preview Hunk" },
      { "<leader>ghi", "<cmd>Gitsigns preview_hunk_inline<cr>", desc = "GitSigns: Preview Hunk Inline" },
      { "<leader>ghb", function() require("gitsigns").blame_line({ full = true }) end, desc = "GitSigns: Blame Line" },
      { "<leader>ghB", function() require("gitsigns").blame() end, desc = "GitSigns: Blame Buffer" },
      { "<leader>ght", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "GitSigns: Toggle Line Blame" },
      { "<leader>ghd", "<cmd>Gitsigns diffthis<cr>", desc = "GitSigns: Diff This" },
      { "<leader>ghD", function() require("gitsigns").diffthis("~") end, desc = "GitSigns: Diff This (~)" },
      { "<leader>ghS", "<cmd>Gitsigns stage_buffer<cr>", desc = "GitSigns: Stage Buffer" },
      { "<leader>ghR", "<cmd>Gitsigns reset_buffer<cr>", desc = "GitSigns: Reset Buffer" },
      { "]h", function() require("gitsigns").nav_hunk("next") end, desc = "GitSigns: Next Hunk" },
      { "[h", function() require("gitsigns").nav_hunk("prev") end, desc = "GitSigns: Prev Hunk" },
    },
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>gv", group = "diffview" },
        { "<leader>gh", group = "gitsigns / hunks" },
      },
    },
  },
}
