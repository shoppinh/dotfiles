#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

link_file() {
  local src="$1"
  local dest="$2"

  if [[ -e "$dest" || -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    echo "  backup: $dest -> $BACKUP_DIR/"
    mv "$dest" "$BACKUP_DIR/"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -sf "$src" "$dest"
  echo "  link: $dest -> $src"
}

echo "Dotfiles dir: $DOTFILES_DIR"
echo "Backups:      $BACKUP_DIR"
echo

link_file "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
link_file "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

link_file "$DOTFILES_DIR/.config/fish" "$HOME/.config/fish"
link_file "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
link_file "$DOTFILES_DIR/.config/karabiner" "$HOME/.config/karabiner"
link_file "$DOTFILES_DIR/.config/kitty" "$HOME/.config/kitty"
link_file "$DOTFILES_DIR/.config/wezterm" "$HOME/.config/wezterm"
link_file "$DOTFILES_DIR/.config/zed" "$HOME/.config/zed"
link_file "$DOTFILES_DIR/.config/sketchybar" "$HOME/.config/sketchybar"
link_file "$DOTFILES_DIR/.config/lazygit" "$HOME/.config/lazygit"
link_file "$DOTFILES_DIR/.config/mise/config.toml" "$HOME/.config/mise/config.toml"
link_file "$DOTFILES_DIR/.config/git/ignore" "$HOME/.config/git/ignore"
link_file "$DOTFILES_DIR/.config/skhd" "$HOME/.config/skhd"
link_file "$DOTFILES_DIR/.config/yabai" "$HOME/.config/yabai"
link_file "$DOTFILES_DIR/.alacritty.toml" "$HOME/.alacritty.toml"

mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty" "$HOME/.config/mise"
link_file "$DOTFILES_DIR/.config/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  cp "$DOTFILES_DIR/.gitconfig.local.example" "$HOME/.gitconfig.local"
  echo
  echo "Created ~/.gitconfig.local — edit with your name and email."
fi

if command -v fish >/dev/null 2>&1; then
  echo
  echo "Installing Fish plugins (Fisher)..."
  fish -c 'fisher update' || echo "  (run \`fish -c fisher update\` manually if this failed)"
fi

echo
echo "Done. Restart your shell or run: exec fish / exec zsh"
echo "SketchyBar: brew services restart sketchybar (after brew install sketchybar)"
