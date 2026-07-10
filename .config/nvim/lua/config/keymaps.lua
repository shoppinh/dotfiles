-- -- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
local map = vim.keymap.set
-- Line/indent manipulation
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")
map("n", "J", "mzJ`z")
map("n", "=ap", "ma=ap'a")
-- Scroll/search centering
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
-- Quickfix
map("n", "]q", "<cmd>cnext<CR>zz")
map("n", "[q", "<cmd>cprev<CR>zz")
map("n", "]l", "<cmd>lnext<CR>zz")
map("n", "[l", "<cmd>lprev<CR>zz")

map("i", "<C-c>", "<Esc>")
-- Disable Ex mode
map("n", "Q", "<nop>")
-- LSP restart (no collision)
map("n", "<leader>zig", "<cmd>LspRestart<cr>")
-- Clipboard yank
map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])
-- Blackhole delete
-- NOTE: relocate to <leader>D if lazyvim.plugins.extras.dap.core is enabled
-- (that extra claims <leader>d as the Debug group root)
map({ "n", "v" }, "<leader>D", '"_d')
-- Paste over selection without clobbering register
-- Relocated off <leader>p — yanky.nvim (coding.yanky extra) owns <leader>p
-- as the yank-history picker in n+x modes
map("x", "<leader>P", [["_dP]], { desc = "Paste over selection (no yank)" })
-- Reload current config file
-------------------------------------------------------------------
-- Personal namespace: <leader>o ("own")
-- All non-LazyVim, non-collision-checked binds live here going forward.
-------------------------------------------------------------------
-- Substitute word under cursor (was <leader>s — collided with Search group)
map(
  "n",
  "<leader>ors",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Substitute word under cursor" }
)
-- chmod +x current file (was <leader>x — collided with Trouble/diagnostics group)
map("n", "<leader>ox", "<cmd>!chmod +x %<CR>", { silent = true, desc = "chmod +x current file" })
-- Cellular automaton rain (was <leader>ca — collided with LSP Code Action)
map("n", "<leader>oa", function()
  require("cellular-automaton").start_animation("make_it_rain")
end, { desc = "Cellular Automaton: Rain" })
local modes = { "n", "i", "v", "x", "s", "o", "t" }

vim.keymap.set(modes, "<Up>", "<Nop>", { desc = "Disabled Arrow Up" })
vim.keymap.set(modes, "<Down>", "<Nop>", { desc = "Disabled Arrow Down" })
vim.keymap.set(modes, "<Left>", "<Nop>", { desc = "Disabled Arrow Left" })
vim.keymap.set(modes, "<Right>", "<Nop>", { desc = "Disabled Arrow Right" })

-- Run current Python file in a Snacks terminal
vim.keymap.set("n", "<leader>cx", function()
  if vim.bo.filetype == "python" then
    Snacks.terminal("python3 " .. vim.fn.shellescape(vim.fn.expand("%:p")))
  else
    vim.notify("Not a Python file", vim.log.levels.WARN)
  end
end, { desc = "Run Python File" })

-- Meta (Alt) key navigation for compact keyboards (DAP)
vim.keymap.set("n", "<M-j>", function() require("dap").step_over() end, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<M-l>", function() require("dap").step_into() end, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<M-h>", function() require("dap").step_out() end, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<M-c>", function() require("dap").continue() end, { desc = "Debug: Start/Continue" })
