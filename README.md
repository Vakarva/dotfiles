# dotfiles

macOS configuration for zsh (powerlevel10k + hand-rolled plugin loader), tmux,
Ghostty, AeroSpace, Karabiner-Elements, git, and mise.

The split: **brew owns ambient defaults, [mise](https://mise.jdx.dev) owns
project precision.** Anything ever run ad-hoc in a shell lives in the
`Brewfile` — always on PATH, refreshed by `brew upgrade`, and the canonical
list of preferred tooling. mise manages language versions globally
(`mise/config.toml`: node) and per-project pins: when a project needs
a specific tool version for team sync, `mise use <tool>@<version>` writes
it to the project's `mise.toml` and shadows the brew copy inside that
directory via PATH precedence. Global mise tools are ambient in interactive
shells too (the activate hook applies `mise/config.toml` everywhere); the
practical difference is that cold-started processes (cron, launchd, GUI
apps) only see brew's PATH — and that brew tools stay fresh via
`brew upgrade`, while mise pins express deliberate versioning intent.

Each language is owned by its most-native manager: **node** → mise (no
native version management), **go** → brew (go.mod's `toolchain` directive
handles per-project versions natively), **python** → uv, **rust** → rustup
(brew-installed, keg-only — PATH set in `zsh/.zprofile`; clippy and rustfmt
ship with the toolchain).

Neovim config lives in its own repo,
[Vakarva/nvim](https://github.com/Vakarva/nvim), cloned directly to
`~/.config/nvim` (no symlink).

## Setup on a new machine

```sh
git clone https://github.com/Vakarva/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
brew bundle install   # installs Homebrew packages, casks, and fonts
./link.sh             # symlinks everything into $HOME (idempotent)
git clone git@github.com:Vakarva/nvim.git ~/.config/nvim
exec zsh              # first launch clones and compiles zsh plugins
mise install          # installs tools pinned in mise/config.toml
rustup default stable # installs the rust toolchain
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
- The JetBrains Mono font is used by Ghostty (`ghostty/config`).
- **Podman on M1/M2**: podman 6 defaults to the libkrun provider, which
  passes `--nested` to krunkit and fails on chips older than M3. The fix is
  `provider = "applehv"` under `[machine]` in
  `~/.config/containers/containers.conf` — kept out of this repo on purpose
  since it's hardware-specific (an M3+ machine may prefer libkrun).
