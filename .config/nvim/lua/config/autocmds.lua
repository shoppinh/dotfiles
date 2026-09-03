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

-- Reset cursor shape and blinking on exit/suspend
autocmd({ "VimLeave", "VimSuspend" }, {
  group = own_group,
  callback = function()
    vim.opt.guicursor = ""
    vim.fn.chansend(vim.v.stderr, "\x1b[2 q")
  end,
})

-- ===================================================================
-- LSP Client Garbage Collector: Auto-stop idle servers with 0 buffers
-- ===================================================================
local lsp_gc_group = augroup("LspGarbageCollector", { clear = true })
local lsp_shutdown_timers = {} ---@type table<number, uv.uv_timer_t>
local IDLE_TIMEOUT_MS = 10 * 60 * 1000 -- 10 minutes grace period

local EXEMPT_CLIENTS = {
  copilot = true,
  supermaven = true,
}

local function get_valid_buffer_count(client)
  local attached_buffers = client.attached_buffers or {}
  local count = 0
  for bufnr, is_attached in pairs(attached_buffers) do
    if is_attached and vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted then
      count = count + 1
    end
  end
  return count
end

local function stop_unused_lsp_clients(notify)
  local stopped = {}
  for _, client in ipairs(vim.lsp.get_clients()) do
    if not EXEMPT_CLIENTS[client.name] and not client.is_stopped() then
      if get_valid_buffer_count(client) == 0 then
        local name = client.name
        local root = vim.fn.fnamemodify(client.config.root_dir or "unknown", ":t")
        client:stop()
        table.insert(stopped, string.format("%s (%s)", name, root))
      end
    end
  end
  if notify and #stopped > 0 then
    vim.notify("[LSP GC] Stopped idle servers: " .. table.concat(stopped, ", "), vim.log.levels.INFO)
  elseif notify then
    vim.notify("[LSP GC] No idle LSP servers found", vim.log.levels.INFO)
  end
end

-- User command to purge idle LSPs immediately
vim.api.nvim_create_user_command("LspStopUnused", function()
  stop_unused_lsp_clients(true)
end, { desc = "Stop LSP servers with 0 active buffers" })

vim.keymap.set("n", "<leader>cu", "<cmd>LspStopUnused<cr>", { desc = "Stop Unused LSPs" })

local function check_and_gc_lsp_clients()
  local active_clients = vim.lsp.get_clients()
  local active_client_ids = {}

  for _, client in ipairs(active_clients) do
    active_client_ids[client.id] = true

    if not EXEMPT_CLIENTS[client.name] and not client.is_stopped() then
      local valid_buffer_count = get_valid_buffer_count(client)

      if valid_buffer_count == 0 then
        if not lsp_shutdown_timers[client.id] then
          local timer = vim.uv.new_timer()
          lsp_shutdown_timers[client.id] = timer
          local client_id = client.id
          local client_name = client.name
          local root_dir = client.config.root_dir or "unknown"

          timer:start(
            IDLE_TIMEOUT_MS,
            0,
            vim.schedule_wrap(function()
              lsp_shutdown_timers[client_id] = nil
              if not timer:is_closing() then
                timer:close()
              end

              local c = vim.lsp.get_client_by_id(client_id)
              if c and not c.is_stopped() and get_valid_buffer_count(c) == 0 then
                c:stop()
                vim.notify(
                  string.format(
                    "[LSP GC] Stopped idle server: %s (%s)",
                    client_name,
                    vim.fn.fnamemodify(root_dir, ":t")
                  ),
                  vim.log.levels.INFO
                )
              end
            end)
          )
        end
      else
        if lsp_shutdown_timers[client.id] then
          local timer = lsp_shutdown_timers[client.id]
          lsp_shutdown_timers[client.id] = nil
          if not timer:is_closing() then
            timer:stop()
            timer:close()
          end
        end
      end
    end
  end

  for cid, timer in pairs(lsp_shutdown_timers) do
    if not active_client_ids[cid] then
      if not timer:is_closing() then
        timer:stop()
        timer:close()
      end
      lsp_shutdown_timers[cid] = nil
    end
  end
end

autocmd({ "BufDelete", "BufWipeout", "LspDetach" }, {
  group = lsp_gc_group,
  callback = function()
    vim.defer_fn(check_and_gc_lsp_clients, 1000)
  end,
})

autocmd("LspAttach", {
  group = lsp_gc_group,
  callback = function(args)
    local client_id = args.data and args.data.client_id
    if client_id and lsp_shutdown_timers[client_id] then
      local timer = lsp_shutdown_timers[client_id]
      lsp_shutdown_timers[client_id] = nil
      if not timer:is_closing() then
        timer:stop()
        timer:close()
      end
    end
  end,
})

autocmd("VimLeavePre", {
  group = lsp_gc_group,
  callback = function()
    for _, timer in pairs(lsp_shutdown_timers) do
      if not timer:is_closing() then
        timer:stop()
        timer:close()
      end
    end
    lsp_shutdown_timers = {}
  end,
})
