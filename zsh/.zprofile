# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH=$PATH:$HOME/.local/bin

# Go: install user binaries into ~/.local/bin
export GOBIN=$HOME/.local/bin

# Rust: brew's rustup is keg-only; cargo installs user binaries into ~/.cargo/bin
export PATH=$PATH:/opt/homebrew/opt/rustup/bin:$HOME/.cargo/bin

# Android Development
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
