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
link_file "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"
link_file "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

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

mkdir -p "$HOME/.config/mise"
if [[ "$OSTYPE" == "darwin"* ]]; then
  mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
  link_file "$DOTFILES_DIR/.config/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
else
  link_file "$DOTFILES_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"
fi

if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  cp "$DOTFILES_DIR/.gitconfig.local.example" "$HOME/.gitconfig.local"
  echo
  echo "Created ~/.gitconfig.local — edit with your name and email."
fi

if [[ ! -f "$HOME/.zshrc.local" ]]; then
  cp "$DOTFILES_DIR/.zshrc.local.example" "$HOME/.zshrc.local"
  echo "Created ~/.zshrc.local — add machine-specific paths and API keys."
fi

if [[ ! -f "$HOME/.zprofile.local" ]]; then
  cp "$DOTFILES_DIR/.zprofile.local.example" "$HOME/.zprofile.local"
  echo "Created ~/.zprofile.local — add login-shell paths (Toolbox, .NET, etc.)."
fi

if command -v brew >/dev/null 2>&1 && [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
  echo
  echo "Installing Homebrew packages from Brewfile..."
  brew bundle install --file="$DOTFILES_DIR/Brewfile" --no-upgrade || \
    echo "  (run \`brew bundle install --file=$DOTFILES_DIR/Brewfile\` manually if this failed)"
fi

if [[ -x "$DOTFILES_DIR/scripts/install-omz-plugins.sh" ]]; then
  echo
  "$DOTFILES_DIR/scripts/install-omz-plugins.sh"
fi

if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  echo
  echo "Installing tmux plugin manager (TPM)..."
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

if command -v fish >/dev/null 2>&1; then
  echo
  echo "Installing Fish plugins (Fisher)..."
  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout 120 fish -c 'fisher update' || echo "  (run \`fish -c fisher update\` manually)"
  elif command -v timeout >/dev/null 2>&1; then
    timeout 120 fish -c 'fisher update' || echo "  (run \`fish -c fisher update\` manually)"
  else
    fish -c 'fisher update' || echo "  (run \`fish -c fisher update\` manually if this failed)"
  fi
fi

echo
echo "Done. Restart your shell or run: exec fish / exec zsh"
