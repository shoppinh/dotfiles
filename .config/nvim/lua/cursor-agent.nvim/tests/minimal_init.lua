local root = vim.fn.getcwd()
vim.opt.rtp:prepend(root)
vim.o.swapfile = false
vim.o.shadafile = "NONE"

package.path = table.concat({
  package.path,
  root .. "/tests/?.lua",
  root .. "/tests/?/init.lua",
}, ";")
