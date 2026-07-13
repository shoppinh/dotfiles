# Spec: Eliminate Redundant Packages and Configs

- **Date**: 2026-07-13
- **Author**: Antigravity
- **Status**: Proposed

## 1. Goal & Context
The goal of this task is to clean up the dotfiles repository by eliminating all duplicate configurations, packages, and conflicting setups that have accumulated. Specifically:
- Consolidate shell prompts on **Starship** and remove **Powerlevel10k**.
- Consolidate directory jumping on **Zoxide** and remove legacy `z` and `autojump`.
- Consolidate version/runtime management on **Mise** and remove legacy `nvm` and `rbenv`.
- Remove duplicate installation of `ghq` (keep Homebrew, remove from Mise).
- Keep only **Ghostty** and **Kitty** terminal configs, removing **Alacritty** (`.alacritty.toml`).
- Clean up Brewfile dependencies (remove custom tap and redundant OMZ plugins).
- Clean up manual plugins loading in `.zshrc` since Oh My Zsh loads them automatically.

## 2. Detailed Scope of Changes

### 2.1. Zsh Config (`.zshrc`)
- Remove Powerlevel10k theme configuration (`ZSH_THEME="powerlevel10k/powerlevel10k"` and sourcing `.p10k.zsh`).
- Remove manual sourcing of `zsh-autosuggestions.zsh` and `zsh-syntax-highlighting.zsh` (since Oh My Zsh loads these from the `plugins=(...)` array).
- Remove the `z` plugin from the OMZ `plugins=(...)` list (replaced by `zoxide`).
- Remove the `autojump` sourcing checks.
- Remove `nvm` initialization commands.
- Remove `rbenv` initialization commands.
- Retain `eval "$(starship init zsh)"` and `eval "$(zoxide init zsh)"`.

### 2.2. Zsh Plugins Script (`scripts/install-omz-plugins.sh`)
- Remove cloning of `powerlevel10k` theme.

### 2.3. Fish Configuration
- Delete the legacy `z` plugin files:
  - `.config/fish/conf.d/z.fish`
  - `.config/fish/functions/__z.fish`
  - `.config/fish/functions/__z_add.fish`
  - `.config/fish/functions/__z_clean.fish`
  - `.config/fish/functions/__z_complete.fish`
- Delete the legacy `nvm` plugin files:
  - `.config/fish/conf.d/nvm.fish`
  - `.config/fish/functions/nvm.fish`
  - `.config/fish/functions/_nvm_index_update.fish`
  - `.config/fish/functions/_nvm_list.fish`
  - `.config/fish/functions/_nvm_version_activate.fish`
  - `.config/fish/functions/_nvm_version_deactivate.fish`

### 2.4. Package Managers
#### Homebrew (`Brewfile`)
- Remove `tap "felixkratz/formulae"` (was only used for `sketchybar`).
- Remove `brew "zsh-autosuggestions"` and `brew "zsh-syntax-highlighting"` (they are managed in `$ZSH_CUSTOM/plugins` via `install-omz-plugins.sh`).
- Retain `brew "ghq"` and `brew "mise"`.

#### Mise (`.config/mise/config.toml`)
- Remove `ghq = "latest"` (already installed via Homebrew).

### 2.5. Symlinks & Terminals (`bootstrap.sh`, `.alacritty.toml`)
- Delete `.alacritty.toml` from the repository.
- Remove Alacritty symlinking from `bootstrap.sh`.
- Remove references to `.alacritty.toml` / Alacritty in `README.md`.

### 2.6. Delete Unused Files
- Delete `.p10k.zsh` (Powerlevel10k config).

## 3. Verification & Safety
- Run `bootstrap.sh` to ensure it links correctly without errors.
- Start a `zsh` session and verify:
  - Starship prompt loads correctly.
  - Autosuggestions and syntax highlighting work.
  - `z` command works (maps to `zoxide`).
  - `node` and `ruby` are managed via `mise`.
  - No errors about missing `nvm`, `rbenv`, `autojump`, or `p10k`.
- Start a `fish` session and verify:
  - Prompt and zoxide work correctly.
  - No legacy `z` or `nvm` warnings/conflicts.
