emulate sh -c '. ~/.profile'

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Android Development
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
