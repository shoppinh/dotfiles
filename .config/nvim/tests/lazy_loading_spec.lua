local failures = {}

local function check(condition, message)
  if not condition then
    failures[#failures + 1] = message
  end
end

local function find_spec(specs, name)
  for _, spec in ipairs(specs) do
    if spec[1] == name then
      return spec
    end
  end
  error("missing plugin spec: " .. name)
end

local theme_specs = dofile(".config/nvim/lua/plugins/theme.lua")
for index = 2, #theme_specs do
  check(theme_specs[index].lazy == true, "alternative theme must be lazy: " .. theme_specs[index][1])
end

local cellular_spec =
  find_spec(dofile(".config/nvim/lua/plugins/cellular-automaton.lua"), "eandrju/cellular-automaton.nvim")
check(cellular_spec.lazy == true, "cellular-automaton.nvim must use lazy.nvim's module loader")

local custom_specs = dofile(".config/nvim/lua/plugins/custom.lua")
local trouble_spec_count = 0
for _, plugin_spec in ipairs(custom_specs) do
  if plugin_spec[1] == "folke/trouble.nvim" then
    trouble_spec_count = trouble_spec_count + 1
  end
end
check(trouble_spec_count == 1, "custom.lua must contain exactly one pinned Trouble spec")

local performance_specs = dofile(".config/nvim/lua/plugins/performance.lua")

local function resolved_events(spec)
  if type(spec.event) == "function" then
    return spec.event(spec, { "LazyFile" })
  end
  return type(spec.event) == "table" and spec.event or { spec.event }
end

local function check_very_lazy(name)
  local spec = find_spec(performance_specs, name)
  check(vim.deep_equal(resolved_events(spec), { "VeryLazy" }), name .. " must load only on VeryLazy")
end

local treesitter_spec = find_spec(performance_specs, "nvim-treesitter/nvim-treesitter")
check(
  treesitter_spec.opts and treesitter_spec.opts.folds and treesitter_spec.opts.folds.enable == false,
  "Treesitter folds must be disabled"
)

local gitsigns_spec = find_spec(performance_specs, "lewis6991/gitsigns.nvim")
check(gitsigns_spec.opts.current_line_blame == false, "Gitsigns current-line blame must default to disabled")
check_very_lazy("lewis6991/gitsigns.nvim")
check_very_lazy("nvim-treesitter/nvim-treesitter-context")
check_very_lazy("gbprod/yanky.nvim")
check_very_lazy("folke/todo-comments.nvim")
check_very_lazy("nvim-mini/mini.hipatterns")

local overrides_lint_loading = false
for _, spec in ipairs(performance_specs) do
  overrides_lint_loading = overrides_lint_loading or spec[1] == "mfussenegger/nvim-lint"
end
check(not overrides_lint_loading, "nvim-lint must retain LazyFile so the first buffer is linted")

local autotag_spec = find_spec(performance_specs, "windwp/nvim-ts-autotag")
check(vim.deep_equal(resolved_events(autotag_spec), {}), "nvim-ts-autotag must not retain the global LazyFile event")
for _, filetype in ipairs({ "html", "typescriptreact", "svelte", "vue", "xml" }) do
  check(vim.tbl_contains(autotag_spec.ft or {}, filetype), "nvim-ts-autotag missing supported filetype: " .. filetype)
end

local turbo_spec = find_spec(custom_specs, "kienmac2k/turbo-log.nvim")
local expected_commands = {
  "TurboLogInsertLog",
  "TurboLogInsertInfo",
  "TurboLogInsertDebug",
  "TurboLogInsertTable",
  "TurboLogInsertWarn",
  "TurboLogInsertError",
  "TurboLogInsertCustom",
  "TurboLogCommentAll",
  "TurboLogUncommentAll",
  "TurboLogDeleteAll",
  "TurboLogCorrectAll",
  "TurboLogPanel",
  "TurboLogFind",
}

local commands = {}
for _, command in ipairs(turbo_spec.cmd or {}) do
  commands[command] = true
end
check(
  type(turbo_spec.cmd) == "table" and #turbo_spec.cmd == #expected_commands,
  "Turbo Log must expose every command trigger"
)
for _, command in ipairs(expected_commands) do
  check(commands[command], "missing Turbo Log command trigger: " .. command)
end

local expected_keys = {
  "<D-k><D-l>",
  "<leader>Tl",
  "<D-k><D-i>",
  "<leader>Ti",
  "<D-k><D-b>",
  "<leader>Td",
  "<D-k><D-t>",
  "<leader>Tt",
  "<D-k><D-r>",
  "<leader>Tw",
  "<D-k><D-e>",
  "<leader>Te",
  "<D-k><D-k>",
  "<leader>Tc",
  "<A-S-c>",
  "<leader>TC",
  "<A-S-u>",
  "<leader>TU",
  "<A-S-d>",
  "<leader>TD",
  "<A-S-x>",
  "<leader>TX",
  "<D-k><D-p>",
  "<leader>Tp",
  "<D-k><D-f>",
  "<leader>Tf",
}

local keys = {}
for _, key_spec in ipairs(turbo_spec.keys or {}) do
  keys[key_spec[1]] = key_spec.mode
end
check(
  type(turbo_spec.keys) == "table" and #turbo_spec.keys == #expected_keys,
  "Turbo Log must expose every key trigger"
)
for _, key in ipairs(expected_keys) do
  check(keys[key] ~= nil, "missing Turbo Log key trigger: " .. key)
  check(vim.deep_equal(keys[key], { "n", "x" }), "Turbo Log key trigger must cover normal and visual modes: " .. key)
end

local git_conflict_spec = find_spec(custom_specs, "akinsho/git-conflict.nvim")
check(git_conflict_spec.event == "BufReadPre", "git-conflict.nvim must load on BufReadPre")

local ui_specs = dofile(".config/nvim/lua/plugins/ui.lua")
local notify_spec = find_spec(ui_specs, "rcarriga/nvim-notify")
check(notify_spec.event == "VeryLazy", "nvim-notify must load on VeryLazy")
local incline_spec = find_spec(ui_specs, "b0o/incline.nvim")
check(incline_spec.event == "VeryLazy", "incline.nvim must load on VeryLazy")

local captured_lazy_opts
local original_lazy = package.loaded.lazy
package.loaded.lazy = {
  setup = function(opts)
    captured_lazy_opts = opts
  end,
}
dofile(".config/nvim/lua/config/lazy.lua")
package.loaded.lazy = original_lazy

check(captured_lazy_opts.defaults.lazy == false, "global plugin lazy-loading default must stay disabled")
check(
  captured_lazy_opts.change_detection and captured_lazy_opts.change_detection.enabled == false,
  "lazy.nvim change detection must be disabled"
)
check(
  vim.tbl_contains(captured_lazy_opts.performance.rtp.disabled_plugins, "netrwPlugin"),
  "netrwPlugin must be disabled"
)

local original_systemlist = vim.fn.systemlist
local original_delete = vim.fn.delete
local original_exepath = vim.fn.exepath
local original_fs_stat = vim.uv.fs_stat
local calls = { systemlist = 0, delete = 0, exepath = 0 }

vim.fn.systemlist = function()
  calls.systemlist = calls.systemlist + 1
  return {}
end
vim.fn.delete = function()
  calls.delete = calls.delete + 1
  return 0
end
vim.fn.exepath = function()
  calls.exepath = calls.exepath + 1
  return ""
end
vim.uv.fs_stat = function()
  return {}
end

local loaded, kulala_specs = pcall(dofile, ".config/nvim/lua/plugins/kulala.lua")
check(loaded, "Kulala spec must load: " .. tostring(kulala_specs))
check(calls.systemlist == 0, "Kulala spec discovery must not run git")
check(calls.delete == 0, "Kulala spec discovery must not delete its grammar cache")
check(calls.exepath == 0, "Kulala spec discovery must not search for the Tree-sitter CLI")

if loaded then
  local kulala_spec = find_spec(kulala_specs, "mistweaverco/kulala.nvim")
  check(type(kulala_spec.opts) == "function", "Kulala local cache and CLI work must be deferred into opts")
  if type(kulala_spec.opts) == "function" then
    local configured, opts = pcall(kulala_spec.opts)
    check(configured, "Kulala opts must run on demand: " .. tostring(opts))
    check(calls.systemlist > 0, "Kulala opts must validate the grammar cache on demand")
    check(calls.delete > 0, "Kulala opts must repair a broken grammar cache on demand")
    check(calls.exepath > 0, "Kulala opts must search for the Tree-sitter CLI on demand")
  end
end

vim.fn.systemlist = original_systemlist
vim.fn.delete = original_delete
vim.fn.exepath = original_exepath
vim.uv.fs_stat = original_fs_stat

assert(#failures == 0, table.concat(failures, "\n"))
