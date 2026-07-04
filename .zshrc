# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-completions
  z
  alias-tips
  zsh-history-substring-search
  fzf-tab
  colored-man-pages
  terraform
  kubectl
  aws
  zsh-syntax-highlighting
)

export ZSH_CUSTOM="$ZSH/custom"

[ -f /usr/share/autojump/autojump.zsh ] && . /usr/share/autojump/autojump.zsh

source $ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

fpath=(~/.oh-my-zsh/custom/plugins/zsh-completions/src $fpath)

eval "$(zoxide init zsh)"

export VISUAL="nvim"
export EDITOR="nvim"

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Common dev paths (adjust in ~/.zshrc.local if needed)
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
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

command -v rbenv >/dev/null && eval "$(rbenv init -)"

eval "$(starship init zsh)"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Machine-specific overrides (not committed)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
