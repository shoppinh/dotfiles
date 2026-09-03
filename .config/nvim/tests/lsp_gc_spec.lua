-- Tests for LSP Garbage Collector and LspStopUnused command
vim.opt.shadafile = "NONE"
vim.opt.runtimepath:prepend(vim.fn.getcwd() .. "/.config/nvim")
vim.go.loadplugins = true

dofile(".config/nvim/lua/config/autocmds.lua")

-- Verify command registration
local commands = vim.api.nvim_get_commands({})
assert(commands["LspStopUnused"] ~= nil, "LspStopUnused user command should be registered")

-- Verify keymap registration
local maps = vim.api.nvim_get_keymap("n")
local found_cu = false
for _, m in ipairs(maps) do
  if m.lhs == "<Space>cu" or (m.desc and m.desc:find("Stop Unused LSPs")) then
    found_cu = true
    break
  end
end
assert(found_cu, "<leader>cu keymap should be registered")

-- Test execution with zero clients (should not error)
vim.cmd("LspStopUnused")

print("LSP GC spec assertions PASSED")
