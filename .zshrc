if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

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

export VISUAL="nvim"
export EDITOR="nvim"
export DOTNET_ROOT="/usr/local/share/dotnet"

source $ZSH/oh-my-zsh.sh

# Common dev paths (adjust in ~/.zshrc.local if needed)
if [[ "$OSTYPE" == "darwin"* ]]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
else
  export ANDROID_HOME="$HOME/Android/Sdk"
  export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
fi

# Keep command precedence aligned with Fish and skip paths that do not exist.
dev_paths=()
for dev_path in \
  "$HOME/.local/bin" \
  "$HOME/.dotnet/tools" \
  "$HOME/.niss/bin" \
  "$HOME/.opencode/bin" \
  "$HOME/.antigravity/antigravity/bin" \
  "$HOME/flutter/bin" \
  "/usr/local/app/bin" \
  "$ANDROID_HOME/emulator" \
  "$ANDROID_HOME/platform-tools" \
  "$ANDROID_SDK_ROOT/cmdline-tools/17.0/bin"
do
  [[ -d "$dev_path" ]] && dev_paths+=("$dev_path")
done
path=("${dev_paths[@]}" $path)
unset dev_path dev_paths

# Google Cloud SDK (install path varies by machine)
[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ] && . "$HOME/google-cloud-sdk/path.zsh.inc"
[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ] && . "$HOME/google-cloud-sdk/completion.zsh.inc"

# Machine-specific overrides (not committed)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Remove duplicate and stale inherited entries, then let Mise own
# managed-runtime precedence.
typeset -U path PATH
clean_path=()
for dev_path in $path; do
  [[ -d "$dev_path" \
    && "$dev_path" != "$HOME/.dotnet" \
    && "$dev_path" != "$HOME/.bun/bin" \
    && "$dev_path" != '~/'* ]] && clean_path+=("$dev_path")
done
path=("${clean_path[@]}")
unset clean_path dev_path
unset MISE_SHELL __MISE_ORIG_PATH __MISE_DIFF __MISE_SESSION
eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
