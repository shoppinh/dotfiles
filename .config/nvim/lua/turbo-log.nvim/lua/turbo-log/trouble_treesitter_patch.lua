-- Neovim 0.12 replaced highlighter._on_line with _on_range.
-- trouble.nvim <= 3.7.1 still registers on_line, which crashes on redraw
-- (e.g. snacks.picker) after the turbo_logs panel enables {text:ts}.
local M = {}

function M.apply()
  local TSHighlighter = vim.treesitter.highlighter
  if type(TSHighlighter._on_range) ~= "function" then
    return false
  end
  -- Old Neovim still has _on_line; leave trouble alone.
  if type(TSHighlighter._on_line) == "function" then
    return false
  end

  local ok, ts = pcall(require, "trouble.view.treesitter")
  if not ok or ts._turbo_log_nvim012_patched then
    return ok == true
  end
  ts._turbo_log_nvim012_patched = true

  local function install_provider()
    local ns = vim.api.nvim_create_namespace("trouble.treesitter")

    local function wrap(name)
      return function(_, win, buf, ...)
        if not ts.cache[buf] then
          return false
        end
        for _, hl in pairs(ts.cache[buf] or {}) do
          if hl.enabled then
            TSHighlighter.active[buf] = hl.highlighter
            local handler = TSHighlighter[name]
            if handler then
              handler(_, win, buf, ...)
            end
          end
        end
        TSHighlighter.active[buf] = nil
      end
    end

    vim.api.nvim_set_decoration_provider(ns, {
      on_win = wrap("_on_win"),
      on_range = wrap("_on_range"),
    })

    vim.api.nvim_create_autocmd("BufWipeout", {
      group = vim.api.nvim_create_augroup("trouble.treesitter.hl", { clear = true }),
      callback = function(ev)
        ts.cache[ev.buf] = nil
      end,
    })
  end

  ts.setup = function()
    if ts.did_setup then
      return
    end
    ts.did_setup = true
    install_provider()
  end

  if ts.did_setup then
    -- Replace a provider already registered with the broken on_line callback.
    install_provider()
  end

  return true
end

return M
