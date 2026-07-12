-- cellular-automaton.nvim: fix grid width with LazyVim statuscolumn / relativenumber.
return {
  {
    "eandrju/cellular-automaton.nvim",
    config = function()
      local load_mod = require("cellular-automaton.load")

      local function get_dominant_hl_group(buffer, i, j)
        local captures = vim.treesitter.get_captures_at_pos(buffer, i - 1, j - 1)
        for c = #captures, 1, -1 do
          if captures[c].capture ~= "spell" and captures[c].capture ~= "@spell" then
            return "@" .. captures[c].capture
          end
        end
        return ""
      end

      local function get_usable_window_width(win_id)
        local info = vim.fn.getwininfo(win_id)[1]
        if not info then
          return vim.api.nvim_win_get_width(win_id)
        end
        return math.max(1, vim.api.nvim_win_get_width(win_id) - (info.textoff or 0))
      end

      function load_mod.load_base_grid(window, buffer)
        local window_width = get_usable_window_width(window)
        local vertical_range = {
          start = vim.fn.line("w0") - 1,
          end_ = vim.fn.line("w$"),
        }
        local horizontal_range = {
          start = vim.fn.winsaveview().leftcol,
          end_ = vim.fn.winsaveview().leftcol + window_width,
        }

        local grid = {}
        for i = 1, vim.api.nvim_win_get_height(window) do
          grid[i] = {}
          for j = 1, window_width do
            grid[i][j] = { char = " ", hl_group = "" }
          end
        end

        local data = vim.api.nvim_buf_get_lines(buffer, vertical_range.start, vertical_range.end_, true)
        for i, line in ipairs(data) do
          for j = 1, window_width do
            local idx = horizontal_range.start + j
            if idx <= #line then
              grid[i][j].char = string.sub(line, idx, idx)
              grid[i][j].hl_group = get_dominant_hl_group(buffer, vertical_range.start + i, idx)
            end
          end
        end
        return grid
      end
    end,
  },
}
