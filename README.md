# dotfiles

macOS configuration for zsh (powerlevel10k + hand-rolled plugin loader), tmux,
Ghostty, AeroSpace, Karabiner-Elements, git, and mise.

Machine-wide tools live in the `Brewfile`; per-project tooling (go, node
versions, opentofu, linters, ...) is managed by [mise](https://mise.jdx.dev)
in each project's `mise.toml`. The global mise config (`mise/config.toml`)
only pins a default node.

Neovim config lives in its own repo at `~/.config/nvim`.

## Setup on a new machine

```sh
git clone https://github.com/Vakarva/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
brew bundle install   # installs Homebrew packages, casks, and fonts
./link.sh             # symlinks everything into $HOME (idempotent)
exec zsh              # first launch clones and compiles zsh plugins
mise install          # installs tools pinned in mise/config.toml
```

Then in tmux, press `prefix + I` to install plugins via [TPM](https://github.com/tmux-plugins/tpm)
(TPM clones itself on first `tmux.conf` load if missing — otherwise clone it to
`~/.config/tmux/plugins/tpm`).

## Notes

- **Karabiner symlink gotcha**: Karabiner-Elements saves settings via
  write-then-rename, which can replace the `karabiner.json` symlink with a
  plain file. After editing settings in the Karabiner GUI, check the symlink
  survived (`ls -l ~/.config/karabiner/karabiner.json`) and re-run `./link.sh`
  if not.
- **Adopting manual installs**: if Ghostty, Karabiner, or the fonts were
  installed by hand rather than by brew, `brew bundle install` will fail on
  those casks — adopt them instead:
  `brew install --cask --adopt ghostty karabiner-elements font-jetbrains-mono`.
- The JetBrains Mono font is used by Ghostty (`ghostty/config`).
