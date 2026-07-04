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

link_file "$DOTFILES_DIR/.config/fish" "$HOME/.config/fish"
link_file "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
link_file "$DOTFILES_DIR/.config/karabiner" "$HOME/.config/karabiner"

if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  cp "$DOTFILES_DIR/.gitconfig.local.example" "$HOME/.gitconfig.local"
  echo
  echo "Created ~/.gitconfig.local — edit with your name and email."
fi

echo
echo "Done. Restart your shell or run: exec fish / exec zsh"
