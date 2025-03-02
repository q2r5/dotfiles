#!/usr/bin/env zsh

set -k                     # Allow comments in shell
setopt auto_cd             # cd by just typing the directory name

export MANPATH=/usr/local/share/man:$MANPATH

export XML_CATALOG_FILES="/usr/local/etc/xml/catalog"

export TERM=xterm-256color

if [[ -z $LANG || -z $LC_CTYPE ]]; then
	export LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8
fi

export TZ=:/etc/localtime

# export ZSH=$(dirname $0)/.oh-my-zsh

if [[ ! -z "$SSH_CLIENT" && -z "$TMUX" ]]; then
	tmux attach || tmux
fi

ssh-add ~/Downloads/LaptopSSH.pem 2>/dev/null

has () {
	type "$1" >/dev/null 2>/dev/null
}

safe_source() {
	[[ -f "$1" ]] && source "$1"
}

export VISUAL='code-insiders -w'
export EDITOR='nano'

# Used to set editor over SSH, only use if editor is non-standard
[[ ! -z "$SSH_CLIENT" ]] && export VISUAL=nano && export EDITOR="$VISUAL"

export STARSHIP_CONFIG=$(dirname $0)/.starship.toml
export DOTNET_CLI_TELEMETRY_OPTOUT=1

export SUDO_PROMPT=$'pass for\033[38;05;5m %u\033[0m '

eval "$(/opt/homebrew/bin/brew shellenv)"

#
#   History
#
HISTFILE=$HOME/.zsh_history
HISTSIZE=999999
SAVEHIST=999999
setopt extended_history   # Record timestamp of command in HISTFILE
setopt hist_ignore_dups   # Ignore duplicated commands history list
setopt share_history      # Save command history before exiting

#This causes pasted URLs to be automatically escaped, without needing to disable globbing.
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# Load RVM into a shell session *as a function*
safe_source "$HOME/.rvm/scripts/rvm"

safe_source $(dirname $0)/.path
safe_source $(dirname $0)/.aliases
safe_source $(dirname $0)/.functions
safe_source $(dirname $0)/.extra

safe_source $(dirname $0)/zsh-autoswitch-virtualenv/autoswitch_virtualenv.plugin.zsh

if [[ "$SHELL" != "/usr/bin/zsh" ]] && has brew; then
	unalias run-help 2>/dev/null
	autoload run-help
	HELPDIR=/usr/local/share/zsh/help
fi

unsetopt LIST_BEEP

## Autocomplete
# if has brew; then
#   FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
# fi
safe_source $(dirname $(gem which colorls))/tab_complete.sh
FPATH="$(dirname $0)/.zfunctions":$FPATH

# Should be called before compinit
zmodload zsh/complist
autoload -U compinit; compinit
setopt MENU_COMPLETE        # Automatically highlight first element of completion menu
setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD     # Complete from both ends of a word.
# Define completers
zstyle ':completion:*' completer _extensions _complete _approximate
# Allow you to select in a menu
zstyle ':completion:*' menu select
# Autocomplete options for cd instead of directory stack
zstyle ':completion:*' complete-options true
zstyle ':completion:*' file-sort modification
# Colors for files and directory
zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commandszstyle ':completion:*' keep-prefix true
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

# safe_source $ZSH/oh-my-zsh.sh
safe_source ~/.iterm2_shell_integration.zsh

case $TERM in
    xterm*)
        precmd () {print -Pn "\e]0;%~\a"}
        ;;
esac

safe_source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
safe_source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
safe_source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

if has thefuck; then
    eval $(thefuck --alias)
fi

#fpath+=($(dirname $0)/pure)
#autoload -U promptinit; promptinit
#prompt pure

if has starship; then
    eval "$(starship init zsh)"
fi
