if vim.g.loaded_cursor_agent then
  return
end
vim.g.loaded_cursor_agent = true

require("cursor-agent")
