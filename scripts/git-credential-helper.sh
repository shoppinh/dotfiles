#!/usr/bin/env bash
set -euo pipefail

# Read stdin inputs into a variable to parse and/or pass downstream
input=$(cat)
host=$(echo "$input" | grep -i '^host=' | cut -d= -f2 || true)

# Detect if we are running in WSL
is_wsl() {
    grep -qi microsoft /proc/version 2>/dev/null
}

# Detect if Windows interop is working in WSL
is_interop_working() {
    is_wsl && "/mnt/c/Windows/System32/cmd.exe" /c "exit" 2>/dev/null
}

# Detect if we are on macOS
is_mac() {
    [[ "$OSTYPE" == "darwin"* ]]
}

if [[ "$host" == "github.com" || "$host" == "gist.github.com" ]] && command -v gh >/dev/null 2>&1; then
    echo "$input" | gh auth git-credential "$@"
elif is_wsl && is_interop_working; then
    GCM_EXE="/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe"
    if [ -f "$GCM_EXE" ]; then
        echo "$input" | "$GCM_EXE" "$@"
    else
        echo "$input" | git credential-cache "$@"
    fi
elif is_mac; then
    echo "$input" | git credential-osxkeychain "$@"
else
    # Standard Linux / WSL with interop disabled
    if command -v git-credential-manager >/dev/null 2>&1 && [[ -n "${GCM_CREDENTIAL_STORE:-}" || "$(git config --global credential.credentialStore || true)" != "" ]]; then
        echo "$input" | git-credential-manager "$@"
    else
        echo "$input" | git credential-cache "$@"
    fi
fi
