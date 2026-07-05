# Activate Powerlevel10k Instant Prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZPLUGINDIR="$HOME/.config/zsh/plugins"
# Refactored from https://github.com/mattmc3/zsh_unplugged
function __plugin-compile() {
    local f
    for f in $@/**/*.zsh{,theme}(N.); do
        [[ $f == */test*/* ]] && continue
        echo "Compiling $f"
        zcompile -R -- "$f"
    done
}
function plugin-load() {
    local repo plugdir initfile initfiles=()
    for repo; do
        plugdir=$ZPLUGINDIR/${repo:t}
        initfile=$plugdir/${repo:t}.plugin.zsh
        if [[ ! -d $plugdir ]]; then
            echo "Cloning $repo..."
            git clone -q --depth 1 --recursive --shallow-submodules https://github.com/$repo $plugdir
            # Special handling for powerlevel10k
            if [[ $repo == "romkatv/powerlevel10k" ]]; then
                echo "Building $repo..."
                make -C $plugdir pkg
            fi
            __plugin-compile $plugdir
            if [[ ! -e $initfile ]]; then
                initfiles=($plugdir/*.{zsh-theme,zsh,sh}(N))
                (( $#initfiles )) || { echo >&2 "No init file '$repo'." && continue }
                ln -sf $initfiles[1] $initfile
            fi
        fi
        source $initfile
    done
}
plugins=(
    Aloxaf/fzf-tab
    romkatv/powerlevel10k
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-syntax-highlighting
)
# Enable the new completion system (compsys)
# NOTE: fzf-tab requires compinit to run before it is loaded
autoload -Uz compinit && compinit
[[ ~/.zcompdump.zwc -nt ~/.zcompdump ]] || zcompile -R ~/.zcompdump

plugin-load $plugins
unfunction plugin-load
source ~/.p10k.zsh

autoload -Uz zmv

ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt inc_append_history    # write to $HISTFILE as commands run, not at shell exit
setopt hist_ignore_all_dups  # drop older duplicates of a repeated command
setopt hist_ignore_space     # don't record commands with a leading space
setopt extended_history      # record timestamp and duration of each command

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
zstyle ':fzf-tab:complete:cd:*' fzf-min-height 8
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define aliases.
alias tree='eza -T -a -I .git'

# Add flags to existing aliases.
alias ls="${aliases[ls]:-ls} -A --color=auto"

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu

function zsh-plugin-update() {
    for d in $ZPLUGINDIR/*/.git(/); do
        plugdir=${d:h}
        echo "Updating ${plugdir:t}..."
        command git -C "$plugdir" pull --ff --recurse-submodules --depth 1 --rebase --autostash
        __plugin-compile $plugdir
    done
}

# ZLE: vi navigation with normal insert-mode deletion
bindkey -v
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^[[3~' delete-char

autoload -U +X bashcompinit && bashcompinit
# NOTE: bare command name so PATH resolves it at completion time (works with mise)
complete -o nospace -C tofu tofu

eval "$(mise activate zsh)"
