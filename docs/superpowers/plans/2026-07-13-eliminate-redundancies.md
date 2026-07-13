# Eliminate Redundancies Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Clean up the dotfiles repository by eliminating all duplicate and redundant configurations, packages, terminal settings, and prompt engines.

**Architecture:** Remove legacy theme and version manager configuration blocks in shell profiles (`.zshrc` and Fish), delete deprecated config and vendor script files, and refine package manager manifests (`Brewfile`, `mise/config.toml`).

**Tech Stack:** Bash, Zsh, Fish, Homebrew, Mise.

## Global Constraints
- Do not remove needed configuration files or dependencies.
- Do not leave any "TBD" or placeholder code.
- Commit frequently (at the end of each task).

---

### Task 1: Clean up Homebrew Dependencies (Brewfile)

**Files:**
- Modify: `Brewfile`

**Interfaces:**
- Consumes: None
- Produces: Simplified `Brewfile`

- [ ] **Step 1: Edit `Brewfile`**
  Modify `Brewfile` to remove the redundant tap `felixkratz/formulae` and packages `zsh-autosuggestions` and `zsh-syntax-highlighting`.
  Replace the contents of `Brewfile` with:
  ```ruby
  # Core dotfiles dependencies (run: brew bundle --file=~/dotfiles/Brewfile)

  brew "bat"
  brew "eza"
  brew "fish"
  brew "fzf"
  brew "gh"
  brew "ghq"
  brew "lazygit"
  brew "mise"
  brew "ripgrep"
  brew "starship"
  brew "tmux"
  brew "yabai"
  brew "zoxide"
  brew "zsh"

  cask "karabiner-elements"
  cask "font-jetbrains-mono-nerd-font"
  cask "font-meslo-lg-nerd-font"
  ```

- [ ] **Step 2: Verify `Brewfile` syntax**
  Run: `brew bundle check --file=Brewfile`
  Expected: Command runs successfully (though it may report some packages are already installed or missing, which is fine).

- [ ] **Step 3: Commit changes**
  ```bash
  git add Brewfile
  git commit -m "refactor: remove redundant tap and packages from Brewfile"
  ```

---

### Task 2: Clean up Zsh Configurations (.zshrc and OMZ plugins script)

**Files:**
- Modify: `.zshrc`
- Modify: `scripts/install-omz-plugins.sh`

**Interfaces:**
- Consumes: Simplified dependencies
- Produces: Starship & Zoxide driven Zsh config without p10k, legacy z, autojump, nvm, or rbenv.

- [ ] **Step 1: Modify `.zshrc`**
  Remove lines 1-4 (Powerlevel10k instant prompt setup).
  Change `ZSH_THEME` to `""`.
  Remove manual plugin sources (autosuggestions, syntax-highlighting, autojump, nvm, rbenv, p10k).
  Update `plugins` array to remove `z` and `alias-tips` if desired (keep it simple).
  Replace `.zshrc` contents with:
  ```zsh
  export ZSH="$HOME/.oh-my-zsh"
  ZSH_THEME=""

  plugins=(
    git
    zsh-autosuggestions
    zsh-completions
    zsh-history-substring-search
    fzf-tab
    colored-man-pages
    terraform
    kubectl
    aws
    zsh-syntax-highlighting
  )

  export ZSH_CUSTOM="$ZSH/custom"

  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  fpath=(~/.oh-my-zsh/custom/plugins/zsh-completions/src $fpath)

  eval "$(zoxide init zsh)"

  export VISUAL="nvim"
  export EDITOR="nvim"

  source $ZSH/oh-my-zsh.sh

  # Common dev paths (adjust in ~/.zshrc.local if needed)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
  else
    export ANDROID_HOME="$HOME/Android/Sdk"
    export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
  fi
  export PATH="$PATH:/usr/local/app/bin"
  export PATH="$PATH:$ANDROID_HOME/emulator"
  export PATH="$PATH:$ANDROID_HOME/tools"
  export PATH="$PATH:$ANDROID_HOME/tools/bin"
  export PATH="$PATH:$ANDROID_HOME/platform-tools"
  export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/17.0/bin:$ANDROID_SDK_ROOT/platform-tools"
  export PATH="$PATH:/usr/local/share/dotnet"
  export PATH="$HOME/.local/bin:$PATH"
  export PATH="$HOME/flutter/bin:$PATH"

  # Google Cloud SDK (install path varies by machine)
  [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ] && . "$HOME/google-cloud-sdk/path.zsh.inc"
  [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ] && . "$HOME/google-cloud-sdk/completion.zsh.inc"

  eval "$(starship init zsh)"

  # Machine-specific overrides (not committed)
  [[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
  ```

- [ ] **Step 2: Modify `scripts/install-omz-plugins.sh`**
  Remove the Powerlevel10k theme cloning step.
  Replace lines 38-45 of `scripts/install-omz-plugins.sh` with:
  ```bash
  echo "Installing Oh My Zsh plugins..."
  clone_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
  clone_plugin "zsh-completions" "https://github.com/zsh-users/zsh-completions"
  clone_plugin "zsh-history-substring-search" "https://github.com/zsh-users/zsh-history-substring-search"
  clone_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"
  clone_plugin "fzf-tab" "https://github.com/Aloxaf/fzf-tab"
  echo "Done."
  ```

- [ ] **Step 3: Verify `.zshrc` parsing**
  Run: `zsh -n .zshrc`
  Expected: No syntax errors.

- [ ] **Step 4: Commit changes**
  ```bash
  git add .zshrc scripts/install-omz-plugins.sh
  git commit -m "refactor: remove p10k, nvm, rbenv, autojump and manual sourcing from zsh configs"
  ```

---

### Task 3: Delete Legacy Fish Plugins and Clean up Mise Config

**Files:**
- Delete: `.config/fish/conf.d/z.fish`
- Delete: `.config/fish/functions/__z.fish`
- Delete: `.config/fish/functions/__z_add.fish`
- Delete: `.config/fish/functions/__z_clean.fish`
- Delete: `.config/fish/functions/__z_complete.fish`
- Delete: `.config/fish/conf.d/nvm.fish`
- Delete: `.config/fish/functions/nvm.fish`
- Delete: `.config/fish/functions/_nvm_index_update.fish`
- Delete: `.config/fish/functions/_nvm_list.fish`
- Delete: `.config/fish/functions/_nvm_version_activate.fish`
- Delete: `.config/fish/functions/_nvm_version_deactivate.fish`
- Modify: `.config/mise/config.toml`

**Interfaces:**
- Consumes: None
- Produces: Clean Fish environment without legacy z/nvm, and clean Mise config without ghq.

- [ ] **Step 1: Delete files**
  Delete all the listed files in terminal.
  Run:
  ```bash
  rm -f .config/fish/conf.d/z.fish \
        .config/fish/functions/__z.fish \
        .config/fish/functions/__z_add.fish \
        .config/fish/functions/__z_clean.fish \
        .config/fish/functions/__z_complete.fish \
        .config/fish/conf.d/nvm.fish \
        .config/fish/functions/nvm.fish \
        .config/fish/functions/_nvm_index_update.fish \
        .config/fish/functions/_nvm_list.fish \
        .config/fish/functions/_nvm_version_activate.fish \
        .config/fish/functions/_nvm_version_deactivate.fish
  ```

- [ ] **Step 2: Modify `.config/mise/config.toml`**
  Remove `ghq = "latest"`.
  Replace contents of `.config/mise/config.toml` with:
  ```toml
  [tools]
  bun = "latest"
  node = "latest"
  python = "latest"
  ruby = "latest"
  rust = "latest"
  ```

- [ ] **Step 3: Verify Fish configuration syntax**
  Run: `fish -n .config/fish/config.fish`
  Expected: No syntax errors.

- [ ] **Step 4: Commit changes**
  ```bash
  git rm .config/fish/conf.d/z.fish \
         .config/fish/functions/__z.fish \
         .config/fish/functions/__z_add.fish \
         .config/fish/functions/__z_clean.fish \
         .config/fish/functions/__z_complete.fish \
         .config/fish/conf.d/nvm.fish \
         .config/fish/functions/nvm.fish \
         .config/fish/functions/_nvm_index_update.fish \
         .config/fish/functions/_nvm_list.fish \
         .config/fish/functions/_nvm_version_activate.fish \
         .config/fish/functions/_nvm_version_deactivate.fish
  git add .config/mise/config.toml
  git commit -m "refactor: delete legacy fish z and nvm plugins, remove ghq from mise"
  ```

---

### Task 4: Clean up Terminal Symlinks and References (Alacritty & P10k)

**Files:**
- Delete: `.p10k.zsh`
- Delete: `.alacritty.toml`
- Modify: `bootstrap.sh`
- Modify: `README.md`

**Interfaces:**
- Consumes: None
- Produces: clean bootstrap process and README

- [ ] **Step 1: Delete configuration files**
  Run:
  ```bash
  rm -f .p10k.zsh .alacritty.toml
  ```

- [ ] **Step 2: Modify `bootstrap.sh`**
  Remove link of `.alacritty.toml`.
  Replace lines 33-46 of `bootstrap.sh` with:
  ```bash
  link_file "$DOTFILES_DIR/.config/fish" "$HOME/.config/fish"
  link_file "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"
  link_file "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
  link_file "$DOTFILES_DIR/.config/kitty" "$HOME/.config/kitty"
  link_file "$DOTFILES_DIR/.config/zed" "$HOME/.config/zed"
  link_file "$DOTFILES_DIR/.config/lazygit" "$HOME/.config/lazygit"
  link_file "$DOTFILES_DIR/.config/mise/config.toml" "$HOME/.config/mise/config.toml"
  link_file "$DOTFILES_DIR/.config/git/ignore" "$HOME/.config/git/ignore"
  link_file "$DOTFILES_DIR/scripts/tmux-sessionizer" "$HOME/.local/bin/tmux-sessionizer"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    link_file "$DOTFILES_DIR/.config/karabiner" "$HOME/.config/karabiner"
    link_file "$DOTFILES_DIR/.config/yabai" "$HOME/.config/yabai"
  fi
  ```

- [ ] **Step 3: Modify `README.md`**
  Remove rows/references to `.p10k.zsh` and `.alacritty.toml` from the tables.
  Change README description for `.zshrc` to:
  - `.zshrc` | Oh My Zsh + Starship prompt
  Remove the `.alacritty.toml` line from contents.
  Remove "Alacritty terminal (minimal)" description.

- [ ] **Step 4: Commit changes**
  ```bash
  git rm .p10k.zsh .alacritty.toml
  git add bootstrap.sh README.md
  git commit -m "refactor: delete p10k and alacritty config files and remove from bootstrap and README"
  ```

---

### Task 5: Final Validation & End-to-End Testing

**Files:**
- Test: `bootstrap.sh`

**Interfaces:**
- Consumes: All cleaned components
- Produces: Fully bootstrapped local environment with no redundant warnings.

- [ ] **Step 1: Run `bootstrap.sh` in dry-run/mock mode or run locally**
  Run: `./bootstrap.sh`
  Expected: Command completes successfully, links all configurations (backup/link messages), and triggers fisher/omz updates without errors.

- [ ] **Step 2: Commit any fixes (if necessary)**
  If any bugs are found during testing, fix and commit.
