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

eval "$(zoxide init zsh)"
eval "$(mise activate zsh)"

export VISUAL="nvim"
export EDITOR="nvim"

source $ZSH/oh-my-zsh.sh

# Common dev paths (adjust in ~/.zshrc.local if needed)
if [[ "$OSTYPE" == "darwin"* ]]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
else
  export ANDROID_HOME="$HOME/Android/Sdk"
  export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
fi
export PATH="$PATH:/usr/local/app/bin"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/tools"
export PATH="$PATH:$ANDROID_HOME/tools/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/17.0/bin:$ANDROID_SDK_ROOT/platform-tools"
export PATH="$PATH:/usr/local/share/dotnet"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/flutter/bin:$PATH"

# Google Cloud SDK (install path varies by machine)
[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ] && . "$HOME/google-cloud-sdk/path.zsh.inc"
[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ] && . "$HOME/google-cloud-sdk/completion.zsh.inc"

eval "$(starship init zsh)"

# Machine-specific overrides (not committed)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
