local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

-- ==========================================
-- 1. Core & WSL Integration
-- ==========================================
config.default_domain = 'WSL:Ubuntu'

-- Performance & Rendering
config.front_end = 'WebGpu'
config.max_fps = 120
config.animation_fps = 120

-- Mouse & Scrolling
config.scrollback_lines = 10000
config.hide_mouse_cursor_when_typing = true

-- Window Layout & Aesthetics
config.color_scheme = 'Catppuccin Mocha'
config.font = wezterm.font_with_fallback({
  'JetBrains Mono',
  'JetBrainsMono Nerd Font',
  'FiraCode Nerd Font',
  'Symbols Nerd Font Mono',
})
config.font_size = 9
config.line_height = 1.1

config.window_decorations = 'RESIZE'
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 6,
}

config.background = {
  {
    source = {
      File = 'F:/NSFW/Landscape/makima_by_lxlbanner_dlpw67m-pre.png',
    },
    hsb = { brightness = 0.15 },
    opacity = 0.7,
  },
}

config.inactive_pane_hsb = {
  saturation = 0.85,
  brightness = 0.7,
}

-- Tab Bar Configuration
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 32

-- ==========================================
-- 2. Leader Key & Smart-Splits Neovim Setup
-- ==========================================
config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 1000 }

-- Helper function to check if active pane is running Neovim/Vim
local function is_vim(pane)
  local process_name = pane:get_foreground_process_name()
  if not process_name then
    return false
  end
  return process_name:find('nvim') or process_name:find('vim')
end

-- Smart navigation: Switch between Neovim splits and WezTerm panes
local function conditional_activate_pane(window, pane, pane_direction, vim_key)
  if is_vim(pane) then
    window:perform_action(act.SendKey({ key = vim_key, mods = 'CTRL' }), pane)
  else
    window:perform_action(act.ActivatePaneDirection(pane_direction), pane)
  end
end

-- Smart resizing: Resize Neovim splits or WezTerm panes
local function conditional_resize_pane(window, pane, pane_direction, vim_key)
  if is_vim(pane) then
    window:perform_action(act.SendKey({ key = vim_key, mods = 'ALT' }), pane)
  else
    window:perform_action(act.AdjustPaneSize({ pane_direction, 5 }), pane)
  end
end

-- Keybindings
config.keys = {
  -- ----------------------------------------------------
  -- Smart Splits: CTRL + h/j/k/l (Neovim + WezTerm)
  -- ----------------------------------------------------
  {
    key = 'h',
    mods = 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      conditional_activate_pane(win, pane, 'Left', 'h')
    end),
  },
  {
    key = 'j',
    mods = 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      conditional_activate_pane(win, pane, 'Down', 'j')
    end),
  },
  {
    key = 'k',
    mods = 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      conditional_activate_pane(win, pane, 'Up', 'k')
    end),
  },
  {
    key = 'l',
    mods = 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      conditional_activate_pane(win, pane, 'Right', 'l')
    end),
  },

  -- Smart Resizing: ALT + h/j/k/l (Neovim + WezTerm)
  {
    key = 'h',
    mods = 'ALT',
    action = wezterm.action_callback(function(win, pane)
      conditional_resize_pane(win, pane, 'Left', 'h')
    end),
  },
  {
    key = 'j',
    mods = 'ALT',
    action = wezterm.action_callback(function(win, pane)
      conditional_resize_pane(win, pane, 'Down', 'j')
    end),
  },
  {
    key = 'k',
    mods = 'ALT',
    action = wezterm.action_callback(function(win, pane)
      conditional_resize_pane(win, pane, 'Up', 'k')
    end),
  },
  {
    key = 'l',
    mods = 'ALT',
    action = wezterm.action_callback(function(win, pane)
      conditional_resize_pane(win, pane, 'Right', 'l')
    end),
  },

  -- ----------------------------------------------------
  -- Leader Key Actions (CTRL+A)
  -- ----------------------------------------------------
  -- Splits
  { key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  { key = '\\', mods = 'LEADER', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  { key = '-', mods = 'LEADER', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane({ confirm = true }) },

  -- Tabs
  { key = 'c', mods = 'LEADER', action = act.SpawnTab('CurrentPaneDomain') },
  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine({
      description = 'Rename Tab:',
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
  { key = '1', mods = 'LEADER', action = act.ActivateTab(0) },
  { key = '2', mods = 'LEADER', action = act.ActivateTab(1) },
  { key = '3', mods = 'LEADER', action = act.ActivateTab(2) },
  { key = '4', mods = 'LEADER', action = act.ActivateTab(3) },
  { key = '5', mods = 'LEADER', action = act.ActivateTab(4) },
  { key = '6', mods = 'LEADER', action = act.ActivateTab(5) },
  { key = '7', mods = 'LEADER', action = act.ActivateTab(6) },
  { key = '8', mods = 'LEADER', action = act.ActivateTab(7) },
  { key = '9', mods = 'LEADER', action = act.ActivateTab(8) },

  -- Workspaces
  { key = 'w', mods = 'LEADER', action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }) },
  {
    key = 'W',
    mods = 'LEADER|SHIFT',
    action = act.PromptInputLine({
      description = 'Enter name for new workspace:',
      action = wezterm.action_callback(function(window, pane, line)
        if line and #line > 0 then
          window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
        end
      end),
    }),
  },
  { key = 'n', mods = 'LEADER', action = act.SwitchWorkspaceRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.SwitchWorkspaceRelative(-1) },

  -- Productivity Tools
  { key = 's', mods = 'LEADER', action = act.QuickSelect },
  { key = '/', mods = 'LEADER', action = act.Search({ CaseSensitiveString = 'CaseSensitiveString' }) },
  { key = 'l', mods = 'LEADER', action = act.ShowLauncher },

  -- Utilities & OS Binds
  { key = 'Enter', mods = 'ALT', action = act.ToggleFullScreen },
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo('Clipboard') },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom('Clipboard') },
}

-- ==========================================
-- 3. Custom Status Bar & Tab Bar Styling
-- ==========================================
wezterm.on('update-right-status', function(window, pane)
  local cells = {}

  -- Leader Key Indicator
  if window:leader_is_active() then
    table.insert(cells, { Background = { Color = '#f38ba8' } })
    table.insert(cells, { Foreground = { Color = '#11111b' } })
    table.insert(cells, { Attribute = { Intensity = 'Bold' } })
    table.insert(cells, { Text = ' LEADER ' })
  end

  -- Active Workspace
  local workspace_name = window:active_workspace()
  table.insert(cells, { Background = { Color = '#1e1e2e' } })
  table.insert(cells, { Foreground = { Color = '#89b4fa' } })
  table.insert(cells, { Text = ' 󰖲 ' .. workspace_name .. ' ' })

  -- Current Working Directory
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    local cwd = cwd_uri.file_path or ''
    -- Trim directory path to basename or last 2 levels
    local trimmed_cwd = cwd:match('([^/]+/[^/]+)/?$') or cwd:match('([^/]+)/?$') or cwd
    table.insert(cells, { Foreground = { Color = '#a6e3a1' } })
    table.insert(cells, { Text = '  ' .. trimmed_cwd .. ' ' })
  end

  -- WSL Ubuntu Badge
  table.insert(cells, { Foreground = { Color = '#fab387' } })
  table.insert(cells, { Text = ' 🐧 WSL:Ubuntu ' })

  -- Local Time
  local date = wezterm.strftime(' %H:%M ')
  table.insert(cells, { Foreground = { Color = '#cdd6f4' } })
  table.insert(cells, { Text = ' 󰥔 ' .. date })

  window:set_right_status(wezterm.format(cells))
end)

-- Custom Tab Title Formatting
wezterm.on('format-tab-title', function(tab, tabs, panes, config_opts, hover, max_width)
  local active_bg = '#89b4fa'
  local active_fg = '#11111b'
  local inactive_bg = '#181825'
  local inactive_fg = '#a6adc8'

  local bg = tab.is_active and active_bg or inactive_bg
  local fg = tab.is_active and active_fg or inactive_fg

  local title = tab.active_pane.title
  if #title > max_width - 4 then
    title = wezterm.truncate_right(title, max_width - 4) .. '…'
  end

  return {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = ' ' .. (tab.tab_index + 1) .. ': ' .. title .. ' ' },
  }
end)

-- ==========================================
-- 4. Launch Menu Entries
-- ==========================================
config.launch_menu = {
  {
    label = 'WSL: Ubuntu',
    domain = { DomainName = 'WSL:Ubuntu' },
  },
  {
    label = 'PowerShell Core',
    args = { 'pwsh.exe', '-NoLogo' },
  },
  {
    label = 'Command Prompt',
    args = { 'cmd.exe' },
  },
}

return config
