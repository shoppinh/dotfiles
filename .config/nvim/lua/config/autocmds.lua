-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local own_group = augroup("OwnGroup", { clear = true })

-- Automatically remove trailing whitespace on save
autocmd("BufWritePre", {
  group = own_group,
  pattern = "*",
  command = [[%s/\s\+$//e]],
})
