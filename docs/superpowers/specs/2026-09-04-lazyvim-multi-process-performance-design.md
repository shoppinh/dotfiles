# LazyVim Multi-Process Performance

Date: 2026-09-04
Status: Approved design

## Context

The current LazyVim configuration registers 95 plugins but loads only five for an empty headless startup. A warm empty startup reaches LazyDone in about 109 ms. Opening a representative Lua file reaches `NVIM STARTED` in about 365 ms, with Treesitter folding alone consuming about 49 ms. Four concurrent warm empty processes complete in about 140 ms wall-clock time, while four processes opening a Lua file complete in about 310 ms.

The configuration already limits several multi-process costs: Lazy's update checker is disabled, Snacks Explorer watching is disabled, LSP workspace file watching is disabled, BasedPyright analyzes open files, and Roslyn limits background analysis to open files.

## Goal

Improve both perceived source-file startup and aggregate idle resource use when several Neovim processes run concurrently, without removing any configured language stack or delaying core editing and LSP availability.

## Non-goals

- Remove TypeScript, .NET, Python, Docker, Tailwind, JSON, YAML, TOML, or Markdown support.
- Globally force every plugin to lazy-load.
- Reuse one Neovim server process across projects.
- Delay Mason or LSP startup beyond the initial file-read lifecycle.
- Change the existing tmux cursor-flicker fix.

## Design

### Remove unused critical-path work

Disable Treesitter folds and LSP folding integration by default. The user rarely uses folding, while Treesitter fold initialization is the largest measured source-file startup cost. Treesitter highlighting, indentation, text objects, and LSP features remain enabled.

Disable Gitsigns current-line blame by default. The feature remains available on demand through `:Gitsigns toggle_current_line_blame`, avoiding continuous blame work in every process.

Disable Neovim's `netrwPlugin`, because Snacks Explorer already provides file exploration.

### Defer non-core UI

Load `nvim-notify` on `VeryLazy` instead of during the initial startup path. Early messages may use Neovim's built-in notifier until `nvim-notify` activates.

Load Incline on LazyVim's `LazyFile` event instead of `BufReadPre`. Its floating filename appears immediately after the first file is ready rather than blocking the file-open critical path. Preserve its tmux-specific cursorline behavior.

### Reduce per-process background lifetime

Disable lazy.nvim configuration-change detection. Configuration edits take effect after restarting Neovim, removing one long-lived watcher from each process.

Reduce the idle LSP shutdown grace period from ten minutes to three minutes. Active clients and attached buffers are unaffected; clients with no listed buffers release resources sooner.

### Keep explicit loading contracts

Keep `defaults.lazy = false`. Each deferred custom plugin must have an explicit event, command, filetype, key, or deliberate `lazy = true` contract. This avoids the unexpected behavior that can result from globally changing plugin defaults.

Remove the duplicated pinned Trouble specification from `custom.lua`. Keep one identical specification, so version pinning and behavior do not change.

## Verification

Extend the existing Neovim configuration tests before changing production configuration. Tests must cover:

- Treesitter and LSP folding are disabled.
- Gitsigns current-line blame defaults to disabled but the plugin remains configured.
- `nvim-notify` uses `VeryLazy` and Incline uses `LazyFile`.
- Lazy change detection is disabled and `netrwPlugin` is in the disabled runtime-plugin list.
- The idle LSP timeout is three minutes.
- Exactly one pinned Trouble specification remains in `custom.lua`.
- All existing language configuration tests still pass.

Run every `.config/nvim/tests/*_spec.lua` file with a clean headless Neovim. Run a real-config smoke test and confirm the empty-start loaded-plugin set does not unexpectedly grow.

Benchmark warm runs before and after the change using the same Neovim executable, repository, file, cache state, and headless command. Compare medians rather than individual runs.

## Acceptance criteria

- Median representative source-file startup improves by at least 15%.
- Median empty startup does not regress by more than 5%.
- Four-process warm startup does not regress.
- No configured language stack or existing test is removed.
- The cursor-flicker configuration remains unchanged.
