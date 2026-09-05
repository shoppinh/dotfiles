# =============================================================================
# 1. ENVIRONMENT VARIABLES & PATHS (Global)
# =============================================================================

# Dynamically source the entire Homebrew ecosystem environment
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
else if test -x /usr/local/bin/brew
    eval (/usr/local/bin/brew shellenv)
end

# Set Global Editor & Preferences
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx DOTNET_ROOT /usr/local/share/dotnet
set fish_greeting ""

# Android SDK Environment Variables
if test (uname) = "Darwin"
    set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
    set -gx ANDROID_SDK_ROOT "$HOME/Library/Android/sdk"
else
    set -gx ANDROID_HOME "$HOME/Android/Sdk"
    set -gx ANDROID_SDK_ROOT "$HOME/Android/Sdk"
end

# Build PATH from this config on every shell start. Global scope prevents
# fish_add_path from persisting stale entries in fish_user_paths.
fish_add_path --global --prepend \
    ~/.local/bin \
    ~/.dotnet/tools \
    ~/.niss/bin \
    ~/.opencode/bin \
    ~/.antigravity/antigravity/bin \
    ~/flutter/bin \
    /usr/local/app/bin \
    $ANDROID_HOME/emulator \
    $ANDROID_HOME/platform-tools \
    $ANDROID_SDK_ROOT/cmdline-tools/17.0/bin

# Google Cloud SDK (install separately; path varies by machine)
set -l _gcloud_path_fish "$HOME/google-cloud-sdk/path.fish.inc"
if test -f $_gcloud_path_fish
    source $_gcloud_path_fish
end

# Local overrides (machine-specific paths, secrets) — not committed
set -l _local_config (dirname (status --current-filename))/config-local.fish
if test -f $_local_config
    source $_local_config
end

# Drop stale inherited entries, including the literal ~/.dotnet/tools path
# added by some .NET installers. The correct absolute tools path is above.
set -l _clean_path
for _path_entry in $PATH
    if test -d "$_path_entry" \
            && test "$_path_entry" != "$HOME/.dotnet" \
            && test "$_path_entry" != "$HOME/.bun/bin" \
            && not string match --quiet '~/*' "$_path_entry"
        set --append _clean_path "$_path_entry"
    end
end
set -gx PATH $_clean_path
set --erase _clean_path _path_entry

# =============================================================================
# 2. INTERACTIVE-ONLY INIT (Faster non-interactive shells)
# =============================================================================
if status is-interactive

    # Setup aliases since paths are now fully loaded
    if type -q nvim
        alias vim nvim
    end

    if type -q eza
        alias ll "eza -l -g --icons"
        alias lla "ll -a"
    end

    # Key Bindings & Fuzzy Finder Configurations
    fzf_configure_bindings --directory=\e\cf

    # Runtime activation must follow every static and local PATH change.
    # Clear a parent shell's Mise session so it cannot restore that shell's PATH.
    set --erase MISE_SHELL __MISE_ORIG_PATH __MISE_DIFF __MISE_SESSION
    mise activate fish | source
    zoxide init fish --cmd z | source
    starship init fish | source
end
