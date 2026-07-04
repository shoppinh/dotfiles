---@class CursorAgent
local M = {}

local config = require("cursor-agent.config")
local commands = require("cursor-agent.commands")

---@param user_opts? table
function M.setup(user_opts)
  config.setup(user_opts)
  commands.setup_commands()
end

return M
