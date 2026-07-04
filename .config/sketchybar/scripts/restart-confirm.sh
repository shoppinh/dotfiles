#!/usr/bin/env bash
set -euo pipefail

answer=$(osascript -e 'button returned of (display dialog "Restart this Mac?" buttons {"Cancel", "Restart"} default button "Cancel" with icon caution)')

if [[ "$answer" == "Restart" ]]; then
  osascript -e 'tell app "System Events" to restart'
fi
