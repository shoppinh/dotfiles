# dotfiles

Personal shell and editor configuration for macOS.

## Contents

| Path | Description |
|------|-------------|
| `.gitconfig` | Git defaults (name/email in local override) |
| `.zshrc` | Oh My Zsh + Powerlevel10k + Starship |
| `.p10k.zsh` | Powerlevel10k prompt theme |
| `.config/fish/` | Fish shell, Fisher plugins, fzf bindings |
| `.config/nvim/` | LazyVim-based Neovim setup |
| `.config/starship.toml` | Starship prompt (Fish) |
| `.config/karabiner/` | Keyboard remapping (macOS) |
| `.tmux.conf` | tmux + TPM plugins, lazygit/cursor popups |

## Security

These configs are scanned before push. **Never commit:**

- API keys, tokens, passwords, or credential files
- `~/.gitconfig.local`, `~/.zshrc.local`, `config-local.fish`
- Cloud SDK credentials (`gcloud`, `configstore`, etc.)

Use the `*.example` files for local-only overrides.

## Prerequisites

- [Homebrew](https://brew.sh/)
- [Oh My Zsh](https://ohmyz.sh/) + [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Fish](https://fishshell.com/) + [Fisher](https://github.com/jorgebucaran/fisher)
- [Neovim](https://neovim.io/) (LazyVim bootstraps plugins on first launch)
- [Starship](https://starship.rs/), [zoxide](https://github.com/ajeetdsouza/zoxide), [fzf](https://github.com/junegunn/fzf)
- [tmux](https://github.com/tmux/tmux) + [TPM](https://github.com/tmux-plugins/tpm) (`git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`)

## Install

```bash
git clone https://github.com/kienmac2k/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x bootstrap.sh
./bootstrap.sh
```

Then set your Git identity:

```bash
cp .gitconfig.local.example ~/.gitconfig.local
# edit ~/.gitconfig.local with your name and email
```

## Neovim

On first launch, Lazy.nvim installs plugins automatically. Lock files (`lazy-lock.json`) are gitignored and generated per machine.

## License

Private dotfiles — use at your own risk.
