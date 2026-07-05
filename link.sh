#!/bin/sh
# Symlink dotfiles into $HOME. Idempotent — safe to re-run.
set -eu

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

link() {
    mkdir -p "$(dirname "$2")"
    ln -sfn "$DOTFILES/$1" "$2"
    echo "$2 -> $DOTFILES/$1"
}

link zsh/.zshrc               "$HOME/.zshrc"
link zsh/.zshenv              "$HOME/.zshenv"
link zsh/.zprofile            "$HOME/.zprofile"
link zsh/.p10k.zsh            "$HOME/.p10k.zsh"
link tmux/tmux.conf           "$HOME/.config/tmux/tmux.conf"
link ghostty/config           "$HOME/.config/ghostty/config"
link aerospace/aerospace.toml "$HOME/.config/aerospace/aerospace.toml"
link karabiner/karabiner.json "$HOME/.config/karabiner/karabiner.json"
link git/config               "$HOME/.config/git/config"
link git/ignore               "$HOME/.config/git/ignore"
link mise/config.toml         "$HOME/.config/mise/config.toml"
