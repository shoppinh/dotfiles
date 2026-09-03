vim.opt.shadafile = "NONE"
vim.opt.runtimepath:prepend(vim.fn.getcwd() .. "/.config/nvim")
vim.go.loadplugins = true
vim.lsp.log._set_filename("/tmp/nvim-roslyn-lsp-test.log")

dofile(".config/nvim/init.lua")
vim.lsp.log.set_level(vim.log.levels.OFF)

require("lazy.core.loader").load("roslyn.nvim", { ft = "cs" })

local dotnet = vim.fn.exepath("dotnet")
local expected_root = vim.fs.dirname(assert(vim.uv.fs_realpath(dotnet)))

assert(
  vim.env.DOTNET_ROOT == expected_root,
  ("expected DOTNET_ROOT %s, got %s"):format(expected_root, vim.env.DOTNET_ROOT)
)
assert(vim.lsp.config.roslyn.workspace_required == true, "Roslyn must require a workspace root")
