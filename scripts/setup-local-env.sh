#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSHRC_LOCAL="$HOME/.zshrc.local"
MARKER="# cursor-agent: CURSOR_API_KEY"

if [[ -f "$ZSHRC_LOCAL" ]] && grep -qF "$MARKER" "$ZSHRC_LOCAL" 2>/dev/null; then
  echo "~/.zshrc.local already documents CURSOR_API_KEY."
  exit 0
fi

cat >>"$ZSHRC_LOCAL" <<'EOF'

# cursor-agent: CURSOR_API_KEY
# Generate a new key at https://cursor.com/dashboard (Service Accounts), then:
# export CURSOR_API_KEY="crsr_..."
EOF

echo "Added CURSOR_API_KEY template to ~/.zshrc.local"
echo "Open https://cursor.com/dashboard to rotate the exposed key, then uncomment the export line."

if command -v open >/dev/null 2>&1; then
  open "https://cursor.com/dashboard"
fi
