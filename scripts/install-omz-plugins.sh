#!/usr/bin/env bash
set -euo pipefail

if [[ ! -d "${ZSH:-$HOME/.oh-my-zsh}" ]]; then
  echo "Oh My Zsh not found — install from https://ohmyz.sh first."
  exit 0
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_plugin() {
  local name="$1"
  local repo="$2"
  local dest="$ZSH_CUSTOM/plugins/$name"

  if [[ -d "$dest/.git" ]]; then
    echo "  ok: $name"
    return
  fi

  echo "  clone: $name"
  git clone --depth=1 "$repo" "$dest"
}

clone_theme() {
  local name="$1"
  local repo="$2"
  local dest="$ZSH_CUSTOM/themes/$name"

  if [[ -d "$dest/.git" ]]; then
    echo "  ok: $name (theme)"
    return
  fi

  echo "  clone: $name (theme)"
  git clone --depth=1 "$repo" "$dest"
}

echo "Installing Oh My Zsh plugins and themes..."
clone_theme "powerlevel10k" "https://github.com/romkatv/powerlevel10k.git"
clone_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
clone_plugin "zsh-completions" "https://github.com/zsh-users/zsh-completions"
clone_plugin "zsh-history-substring-search" "https://github.com/zsh-users/zsh-history-substring-search"
clone_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"
clone_plugin "alias-tips" "https://github.com/djui/alias-tips"
clone_plugin "fzf-tab" "https://github.com/Aloxaf/fzf-tab"
echo "Done."
