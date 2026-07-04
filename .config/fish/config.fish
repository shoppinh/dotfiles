# =============================================================================
# 1. ENVIRONMENT VARIABLES & PATHS (Global)
# =============================================================================

# Dynamically source the entire Homebrew ecosystem environment
if test -d /opt/homebrew/bin
    eval (/opt/homebrew/bin/brew shellenv)
end

# Set Global Editor & Preferences
set -gx EDITOR nvim
set -gx VISUAL nvim
set fish_greeting ""

# Android SDK Environment Variables
set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
set -gx ANDROID_SDK_ROOT "$HOME/Library/Android/sdk"

# Add custom application binaries and local binaries to path safely
fish_add_path /usr/local/app/bin
fish_add_path ~/.local/bin
fish_add_path $ANDROID_HOME/emulator
fish_add_path $ANDROID_HOME/tools
fish_add_path $ANDROID_HOME/tools/bin
fish_add_path $ANDROID_HOME/platform-tools
fish_add_path $ANDROID_SDK_ROOT/cmdline-tools/17.0/bin
fish_add_path /usr/local/share/dotnet
fish_add_path ~/flutter/bin
fish_add_path ~/.antigravity/antigravity/bin
fish_add_path ~/.opencode/bin
fish_add_path ~/.niss/bin

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

    # Initialize Starship Prompt and Zoxide
    starship init fish | source
    zoxide init fish --cmd z | source

    # Initialize rbenv (Ruby Environment Manager)
    if type -q rbenv
        rbenv init - fish | source
    end

    # Key Bindings & Fuzzy Finder Configurations
    fzf_configure_bindings --directory=\e\cf
    
    # Map Ctrl+L to accept your auto-suggestions
    bind \cl accept-autosuggestion
    
    # Move "Clear Screen" to Alt+L so you don't lose the ability to clear your terminal
    bind \el 'clear; commandline -f repaint'   

    # brew shellenv runs after conf.d/nvm.fish; keep nvm's node ahead of Homebrew's.
    if set --query nvm_current_version
        set --prepend PATH $nvm_data/$nvm_current_version/bin
    end
    
end
