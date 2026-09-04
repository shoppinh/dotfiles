-- Tests for LSP Garbage Collector and LspStopUnused command
vim.opt.shadafile = "NONE"
vim.opt.runtimepath:prepend(vim.fn.getcwd() .. "/.config/nvim")
vim.go.loadplugins = true

local scheduled_timeout
local fake_timer = {
  start = function(_, timeout)
    scheduled_timeout = timeout
  end,
  stop = function() end,
  close = function() end,
  is_closing = function()
    return false
  end,
}

local original_new_timer = vim.uv.new_timer
local original_defer_fn = vim.defer_fn
local original_get_clients = vim.lsp.get_clients
vim.uv.new_timer = function()
  return fake_timer
end
vim.defer_fn = function(callback)
  callback()
end
vim.lsp.get_clients = function()
  return {
    {
      id = 987654,
      name = "test_lsp",
      attached_buffers = {},
      config = { root_dir = vim.fn.getcwd() },
      is_stopped = function()
        return false
      end,
    },
  }
end

dofile(".config/nvim/lua/config/autocmds.lua")

vim.api.nvim_exec_autocmds("BufDelete", { buffer = 0 })
assert(scheduled_timeout == 3 * 60 * 1000, "idle LSP timer must be scheduled for 3 minutes")

vim.uv.new_timer = original_new_timer
vim.defer_fn = original_defer_fn
vim.lsp.get_clients = original_get_clients

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
