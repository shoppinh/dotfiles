local failures = {}

vim.opt.runtimepath:prepend(vim.fn.getcwd() .. "/.config/nvim/lua/turbo-log.nvim")
vim.opt.runtimepath:prepend(vim.fn.stdpath("data") .. "/lazy/trouble.nvim")
require("trouble").setup({})
require("turbo-log").setup({ setup_keymaps = false })

local buffer = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(buffer)
vim.bo[buffer].filetype = "javascript"

for _, command in ipairs({
  "TurboLogCommentAll",
  "TurboLogUncommentAll",
  "TurboLogDeleteAll",
  "TurboLogCorrectAll",
}) do
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {
    "const value = 1;",
    'console.log("value:", value);',
  })

  local ok, err = pcall(vim.cmd, command)
  if not ok then
    failures[#failures + 1] = command .. ": " .. tostring(err)
  end
end

assert(#failures == 0, table.concat(failures, "\n"))
