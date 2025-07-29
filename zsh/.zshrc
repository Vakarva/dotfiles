function zcompile-many() {
  local f
  for f; do zcompile -R -- "$f".zwc "$f"; done
}

# Clone and compile to wordcode missing plugins.
if [[ ! -e ~/.zsh/fzf-tab/ ]]; then
  git clone --depth=1 https://github.com/Aloxaf/fzf-tab ~/.zsh/fzf-tab
  zcompile-many ~/.zsh/fzf-tab/{fzf-tab.zsh,fzf-tab.plugin.zsh,lib/zsh-ls-colors/ls-colors.zsh}
fi
if [[ ! -e ~/.zsh/zsh-syntax-highlighting ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
  zcompile-many ~/.zsh/zsh-syntax-highlighting/{zsh-syntax-highlighting.zsh,highlighters/*/*.zsh}
fi
if [[ ! -e ~/.zsh/zsh-autosuggestions ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/zsh-autosuggestions
  zcompile-many ~/.zsh/zsh-autosuggestions/{zsh-autosuggestions.zsh,src/**/*.zsh}
fi
if [[ ! -e ~/.zsh/powerlevel10k ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh/powerlevel10k
  make -C ~/.zsh/powerlevel10k pkg
fi

# Activate Powerlevel10k Instant Prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Autoload functions.
autoload -U compinit; compinit
[[ ~/.zcompdump.zwc -nt ~/.zcompdump ]] || zcompile-many ~/.zcompdump
unfunction zcompile-many
autoload -Uz zmv

# Plugins
source ~/.zsh/fzf-tab/fzf-tab.plugin.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme
source ~/.p10k.zsh

# Export environment variables.
export GPG_TTY=$TTY

# fzf-tab configuration
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
# Use tmux to create a popup
zstyle ':fzf-tab:*' fzf-flags --tmux 80%,60% --reverse --color=fg:1,fg+:2 --bind=tab:accept

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define aliases.
alias tree='tree -a -I .git'

# Add flags to existing aliases.
alias ls="${aliases[ls]:-ls} -A --color=auto"

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu

# Configure NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# FROM: https://github.com/nvm-sh/nvm?tab=readme-ov-file#zsh
# place this after nvm initialization!
autoload -U add-zsh-hook

load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version
    nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc

# FROM: https://docs.astral.sh/uv/getting-started/installation/#shell-autocompletion
# uv shell autocompletion
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
