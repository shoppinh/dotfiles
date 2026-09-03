# Neovim Keymaps Cheatsheet

> **Leader Key:** `<leader>` = <kbd>Space</kbd>  
> **macOS Note:** Alt/Option (`<M-*>`) bindings use Left-Option (configured with `macos_option_as_alt left`).

---

## Table of Contents
1. [Fast Pickers & Finders (Snacks.nvim & `;` Shortcuts)](#1-fast-pickers--finders-snacksnvim--)
2. [LSP, Diagnostics & Code Intelligence](#2-lsp-diagnostics--code-intelligence)
3. [Git Workflow (Pickers, Fugitive, Diff & Conflicts)](#3-git-workflow-pickers-fugitive-diff--conflicts)
4. [Harpoon 2 (File Pinning & Fast Switching)](#4-harpoon-2-file-pinning--fast-switching)
5. [Debugging (DAP - Option/Alt & Leader)](#5-debugging-dap---optionalt--leader)
6. [Buffers & Tabs Management](#6-buffers--tabs-management)
7. [File Managers (Yazi & Snacks Explorer)](#7-file-managers-yazi--snacks-explorer)
8. [Turbo-Log (Console & Logging Utilities)](#8-turbo-log-console--logging-utilities)
9. [Editing, Registers, Centering & Motion](#9-editing-registers-centering--motion)
10. [Personal Namespace (`<leader>o`) & Quick Scripts](#10-personal-namespace-leadero--quick-scripts)
11. [Testing (Neotest)](#11-testing-neotest)

---

## 1. Fast Pickers & Finders (Snacks.nvim & `;`)

### Primary Search & Quick Pickers
| Keymap | Mode | Action | Description |
| :--- | :--- | :--- | :--- |
| `<leader><leader>` | `n` | `Snacks.picker.smart()` | **Smart Find Files** (combines open buffers, recent files, and project root) |
| `<leader>ff` | `n` | `Snacks.picker.files()` | Find files in root directory |
| `<leader>fF` | `n` | `Snacks.picker.files({cwd})` | Find files in current working directory |
| `<leader>fr` | `n` | `Snacks.picker.recent()` | Recent / old files history |
| `<leader>fP` | `n` | `Snacks.picker.files({lazy_root})` | Find plugin files |
| `<leader>fc` | `n` | `Snacks.picker.files({config})` | Find Neovim configuration files |
| `<leader>fg` | `n` | `Snacks.picker.git_files()` | Find files tracked by Git |
| `<leader>fp` | `n` | `Snacks.picker.projects()` | Browse recent projects |
| `<leader>/` / `<leader>sg` | `n` | `Snacks.picker.grep()` | Live grep in project root |
| `<leader>sG` | `n` | `Snacks.picker.grep({cwd})` | Live grep in current working directory |
| `<leader>sw` | `n`, `x` | `Snacks.picker.grep_word()` | Grep word under cursor or visual selection (root dir) |
| `<leader>sW` | `n`, `x` | `Snacks.picker.grep_word({cwd})` | Grep word under cursor or visual selection (cwd) |
| `<leader>sb` | `n` | `Snacks.picker.lines()` | Fuzzy find lines in current buffer |
| `<leader>sB` | `n` | `Snacks.picker.grep_buffers()` | Grep across all open buffers |
| `<leader>sR` / `<leader>u` | `n` | `Snacks.picker.undo()` | Interactive **Undo Tree** with live diff preview |
| `<leader>.` | `n` | `Snacks.scratch()` | Toggle floating **Scratchpad** (auto-persisted per filetype) |
| `<leader>S` | `n` | `Snacks.scratch.select()` | Select / browse scratchpads |
| `<leader>un` | `n` | `Snacks.picker.notifications()` | Notification history picker |
| `<leader>sk` | `n` | `Snacks.picker.keymaps()` | Interactive Keymaps finder |
| `<leader>sc` / `<leader>:` | `n` | `Snacks.picker.command_history()` | Command history picker |
| `<leader>sh` | `n` | `Snacks.picker.help()` | Vim help tags picker |
| `<leader>uC` | `n` | `Snacks.picker.colorschemes()` | Colorscheme switcher with live preview |
| `<leader>z` | `n` | `<cmd>ZenMode<cr>` | Toggle **Zen Mode** |

### Muscle-Memory Quick Prefixes (`;` & `\\`)
| Keymap | Mode | Action | Description |
| :--- | :--- | :--- | :--- |
| `;f` | `n` | `Snacks.picker.files({hidden, cwd})` | Find files (includes hidden, cwd) |
| `sf` | `n` | `Snacks.picker.files({buffer_dir})` | Find files in current buffer's directory |
| `;r` | `n` | `Snacks.picker.grep({hidden})` | Live grep (includes hidden) |
| `;w` | `n`, `x` | `Snacks.picker.grep_word({hidden})` | Grep current word or visual selection |
| `;l` | `n` | `Snacks.picker.lines()` | Fuzzy search lines in current buffer |
| `;b` | `n` | `Snacks.picker.grep_buffers()` | Grep across open buffers |
| `\\` | `n` | `Snacks.picker.buffers()` | Switch open buffer |
| `;;` | `n` | `Snacks.picker.resume()` | Resume last picker |
| `;t` | `n` | `Snacks.picker.help()` | Help tags |
| `;e` | `n` | `Snacks.picker.diagnostics()` | Buffer & workspace diagnostics |
| `;s` | `n` | `Snacks.picker.lsp_symbols()` | LSP **Document Symbols** (current file hierarchy) |
| `;S` | `n` | `Snacks.picker.lsp_workspace_symbols()` | LSP **Workspace Symbols** (entire project) |
| `;c` | `n` | `Snacks.picker.lsp_incoming_calls()` | LSP Incoming Calls hierarchy |

---

## 2. LSP, Diagnostics & Code Intelligence

| Keymap | Mode | Action | Description |
| :--- | :--- | :--- | :--- |
| `gd` | `n` | `Snacks.picker.lsp_definitions()` | **Go to Definition** (with preview if multiple) |
| `gr` | `n` | `Snacks.picker.lsp_references()` | **Go to References** |
| `gri` | `n` | `vim.lsp.buf.implementation()` | Go to Implementation |
| `grt` | `n` | `vim.lsp.buf.type_definition()` | Go to Type Definition |
| `gra` / `<leader>ca` | `n` | `vim.lsp.buf.code_action()` | Code Action |
| `grn` / `<leader>cr` | `n` | `vim.lsp.buf.rename()` / `IncRename` | Incremental symbol rename |
| `<leader>cR` | `n` | `Snacks.rename.rename_file()` | **Rename File** (automatically updates project imports) |
| `<leader>cf` | `n` | `LazyVim.format()` | Format document |
| `<leader>cd` / `gl` | `n` | `vim.diagnostic.open_float()` | Line diagnostics popup |
| `[d` / `]d` | `n` | `vim.diagnostic.goto_prev/next()` | Previous / Next diagnostic |
| `[D` / `]D` | `n` | Jump to first / last diagnostic | First / Last diagnostic in buffer |
| `<leader>xx` | `n` | `<cmd>Trouble diagnostics toggle<cr>` | Toggle Trouble diagnostics panel |
| `<leader>xX` | `n` | `<cmd>Trouble diagnostics toggle filter.buf=0<cr>` | Buffer diagnostics (Trouble) |
| `<leader>cs` | `n` | `<cmd>Trouble symbols toggle<cr>` | Symbols outline (Trouble) |
| `<leader>zig` | `n` | `<cmd>LspRestart<cr>` | Restart LSP server |
| `K` | `n` | `vim.lsp.buf.hover()` | Hover documentation |

---

## 3. Git Workflow (Pickers, Fugitive, Diff & Conflicts)

| Keymap | Mode | Action | Description |
| :--- | :--- | :--- | :--- |
| `<leader>gs` | `n` | `Snacks.picker.git_status()` | **Git Status Picker** (with live split diff preview) |
| `<leader>gl` | `n` | `Snacks.picker.git_log()` | Git Commit Log picker |
| `<leader>gL` | `n` | `Snacks.picker.git_log_file()` | Current file's Git history |
| `<leader>gb` | `n` | `Snacks.picker.git_branches()` | Git Branches switcher |
| `<leader>gS` | `n` | `Snacks.picker.git_stash()` | Git Stashes picker |
| `<leader>gd` | `n` | `Snacks.picker.git_diff()` | Git Hunks diff |
| `<leader>go` | `n`, `x` | `Snacks.gitbrowse()` | **Open in Browser** (jumps directly to GitHub/GitLab URL) |
| `<leader>gg` | `n` | `Snacks.lazygit()` | Toggle **LazyGit** floating terminal |
| `gu` | `n` | `<cmd>diffget //2<cr>` | Fugitive 3-way merge: Get target (Left) |
| `gh` | `n` | `<cmd>diffget //3<cr>` | Fugitive 3-way merge: Get merge (Right) |
| `<leader>co` | `n` | Git Conflict: Choose Ours | Resolve merge conflict with *Ours* |
| `<leader>ct` | `n` | Git Conflict: Choose Theirs | Resolve merge conflict with *Theirs* |
| `<leader>cb` | `n` | Git Conflict: Choose Both | Resolve merge conflict with *Both* |
| `[x` / `]x` | `n` | Git Conflict Prev / Next | Navigate merge conflicts |
| `[h` / `]h` | `n` | Gitsigns: Prev / Next Hunk | Navigate git diff hunks |

---

## 4. Harpoon 2 (File Pinning & Fast Switching)

| Keymap | Mode | Action | Description |
| :--- | :--- | :--- | :--- |
| `<leader>a` | `n` | `harpoon:list():add()` | **Add File** to Harpoon list |
| `<leader>A` | `n` | `harpoon:list():prepend()` | Prepend file to Harpoon list |
| `<C-e>` / `<leader>h` | `n` | `harpoon.ui:toggle_quick_menu()` | **Toggle Harpoon UI Menu** |
| `<M-1>` / `<leader>1` | `n` | `harpoon:list():select(1)` | Switch to Harpoon File 1 |
| `<M-2>` / `<leader>2` | `n` | `harpoon:list():select(2)` | Switch to Harpoon File 2 |
| `<M-3>` / `<leader>3` | `n` | `harpoon:list():select(3)` | Switch to Harpoon File 3 |
| `<M-4>` / `<leader>4` | `n` | `harpoon:list():select(4)` | Switch to Harpoon File 4 |
| `<leader>5` – `<leader>9` | `n` | `harpoon:list():select(N)` | Switch to Harpoon Files 5 through 9 |

---

## 5. Debugging (DAP - Option/Alt & Leader)

> Configured with macOS Left-Option as Alt sequences for compact keyboards.

| Keymap | Mnemonic | Function | Description |
| :--- | :--- | :--- | :--- |
| `<M-c>` | **C**ontinue | `dap.continue()` | Start / Continue execution |
| `<M-b>` | **B**reakpoint | `dap.toggle_breakpoint()` | Toggle Breakpoint at current line |
| `<M-n>` / `<M-j>` | **N**ext / Step Over | `dap.step_over()` | Step Over |
| `<M-i>` / `<M-l>` | **I**nto / Step Into | `dap.step_into()` | Step Into |
| `<M-o>` / `<M-h>` | **O**ut / Step Out | `dap.step_out()` | Step Out |
| `<M-p>` | **P**ause | `dap.pause()` | Pause execution |
| `<M-r>` | **R**estart | `dap.restart()` | Restart debugging session |
| `<M-q>` | **Q**uit / Stop | `dap.terminate()` | Stop / Terminate debugging session |
| `<leader>db` | | `dap.toggle_breakpoint()` | Breakpoint (Leader group) |
| `<leader>dB` | | Breakpoint Condition | Set conditional breakpoint |
| `<leader>du` | | `dapui.toggle()` | Toggle DAP UI |
| `<leader>dr` | | `dap.repl.toggle()` | Toggle DAP REPL |

---

## 6. Buffers & Tabs Management

| Keymap | Mode | Action | Description |
| :--- | :--- | :--- | :--- |
| `<Tab>` | `n` | `<Cmd>BufferLineCycleNext<CR>` | Next buffer tab |
| `<S-Tab>` | `n` | `<Cmd>BufferLineCyclePrev<CR>` | Previous buffer tab |
| `L` / `]b` | `n` | `bnext` | Next buffer |
| `H` / `[b` | `n` | `bprevious` | Previous buffer |
| `<leader>bd` | `n` | `Snacks.bufdelete()` | **Close Buffer** (safely preserves window split layout) |
| `<leader>bp` | `n` | `BufferLineTogglePin` | Pin current buffer |
| `<leader>bP` | `n` | Close non-pinned buffers | Delete non-pinned buffers |
| `<leader>bl` | `n` | Close buffers to left | Delete all buffers to the left |
| `<leader>br` | `n` | Close buffers to right | Delete all buffers to the right |

---

## 7. File Managers (Yazi & Snacks Explorer)

| Keymap | Mode | Action | Description |
| :--- | :--- | :--- | :--- |
| `<leader>-` | `n` | `<cmd>Yazi<cr>` | Open **Yazi** file manager (project root) |
| `<leader>_` | `n` | `<cmd>Yazi cwd<cr>` | Open **Yazi** file manager (current file directory) |
| `<C-up>` | `n` | `<cmd>Yazi toggle<cr>` | Toggle Yazi window |
| `<leader>e` / `<leader>fe`| `n` | `Snacks.explorer()` | Open Snacks file tree explorer |

---

## 8. Turbo-Log (Console & Logging Utilities)

| GUI Binding | Terminal Fallback | Description |
| :--- | :--- | :--- |
| `<D-k><D-l>` | `<leader>Tl` | Insert `console.log` / logging statement |
| `<D-k><D-i>` | `<leader>Ti` | Insert `console.info` |
| `<D-k><D-b>` | `<leader>Td` | Insert `console.debug` |
| `<D-k><D-t>` | `<leader>Tt` | Insert `console.table` |
| `<D-k><D-r>` | `<leader>Tw` | Insert `console.warn` |
| `<D-k><D-e>` | `<leader>Te` | Insert `console.error` |
| `<D-k><D-k>` | `<leader>Tc` | Insert custom log |
| `<M-C>` | `<leader>TC` | Comment all turbo logs |
| `<M-U>` | `<leader>TU` | Uncomment all turbo logs |
| `<M-D>` | `<leader>TD` | Delete all turbo logs |
| `<M-X>` | `<leader>TX` | Correct line numbers in all turbo logs |
| `<D-k><D-p>` | `<leader>Tp` | Toggle Turbo-Log panel |
| `<D-k><D-f>` | `<leader>Tf` | Find all turbo logs |

---

## 9. Editing, Registers, Centering & Motion

| Keymap | Mode | Action | Description |
| :--- | :--- | :--- | :--- |
| `J` | `v` | `:m '>+1<CR>gv=gv` | Move selected lines **down** (auto-indents) |
| `K` | `v` | `:m '<-2<CR>gv=gv` | Move selected lines **up** (auto-indents) |
| `J` | `n` | `mzJ`z` | Join line below while keeping cursor fixed |
| `<C-d>` | `n` | `<C-d>zz` | Half-page down & center screen |
| `<C-u>` | `n` | `<C-u>zz` | Half-page up & center screen |
| `n` / `N` | `n` | `nzzzv` / `Nzzzv` | Next / previous search result & center screen |
| `[q` / `]q` | `n` | `cprev` / `cnext` | Previous / next quickfix list item |
| `<leader>y` / `<leader>Y` | `n`, `v` | `"+y` / `"+Y` | **Yank to system clipboard** |
| `<leader>D` | `n`, `v` | `"_d` | **Blackhole delete** (delete without overwriting clipboard) |
| `<leader>P` | `x` | `"_dP` | **Paste over selection** (retains your copied text) |
| `<leader>p` | `n` | `Yanky` | Open yank register history picker |
| `<C-f>` | `n` | `tmux-sessionizer` | Trigger `tmux-sessionizer` popup |
| `<Up>/<Down>/<Left>/<Right>` | All | `<Nop>` | **Disabled arrow keys** (encourages Vim motions) |

---

## 10. Personal Namespace (`<leader>o`) & Quick Scripts

| Keymap | Mode | Action | Description |
| :--- | :--- | :--- | :--- |
| `<leader>ors` | `n` | `:%s/\<<C-r><C-w>\>/...` | Substitute word under cursor across entire file |
| `<leader>ox` | `n` | `!chmod +x %` | Make current file executable (`chmod +x`) |
| `<leader>oa` | `n` | `CellularAutomaton make_it_rain` | Fun matrix rain animation on current buffer |
| `<leader>ou` | `n` | `<cmd>UndotreeToggle<cr>` | Toggle traditional Undotree sidebar |
| `<leader>cx` | `n` | Python runner | Run current Python script in a floating Snacks terminal |
| `<leader>ch` | `n` | Browser runner | Open current HTML file in default macOS browser |

---

## 11. Testing (Neotest)

| Keymap | Mode | Action | Description |
| :--- | :--- | :--- | :--- |
| `<leader>tr` | `n` | `neotest.run.run()` | Run nearest test |
| `<leader>tt` | `n` | `neotest.run.run(vim.fn.expand("%"))` | Run all tests in current file |
| `<leader>tT` | `n` | `neotest.run.run(vim.uv.cwd())` | Run all test files in project |
| `<leader>td` | `n` | `neotest.run.run({strategy = "dap"})` | Debug nearest test |
| `<leader>ts` | `n` | `neotest.summary.toggle()` | Toggle test summary sidebar |
| `<leader>to` | `n` | `neotest.output.open({enter = true})` | Show test output popup |
| `<leader>tO` | `n` | `neotest.output_panel.toggle()` | Toggle test output panel |
| `<leader>tl` | `n` | `neotest.run.run_last()` | Run last test |
| `<leader>tS` | `n` | `neotest.run.stop()` | Stop running test |
| `<leader>tw` | `n` | `neotest.watch.toggle()` | Toggle test file watch mode |
