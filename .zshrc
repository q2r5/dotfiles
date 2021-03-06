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

export GOPATH=/usr/local/lib/go

export STARSHIP_CONFIG=$(dirname $0)/.starship.toml
export DOTNET_CLI_TELEMETRY_OPTOUT=1

export SUDO_PROMPT=$'pass for\033[38;05;5m %u\033[0m '

#
#   History
#
HISTSIZE=999999
SAVEHIST=999999
setopt extended_history   # Record timestamp of command in HISTFILE
setopt hist_ignore_dups   # Ignore duplicated commands history list
setopt share_history      # Save command history before exiting

safe_source $(dirname $0)/.path
safe_source $(dirname $0)/.aliases
safe_source $(dirname $0)/.functions
safe_source $(dirname $0)/.extra

# Load RVM into a shell session *as a function*
safe_source "$HOME/.rvm/scripts/rvm"

if [[ "$SHELL" != "/usr/bin/zsh" ]] && has brew; then
	unalias run-help 2>/dev/null
	autoload run-help
	HELPDIR=/usr/local/share/zsh/help
fi

if has brew; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

fpath=("$(dirname $0)/.zfunctions" $fpath)

# safe_source $ZSH/oh-my-zsh.sh
safe_source ~/.iterm2_shell_integration.zsh

case $TERM in
    xterm*)
        precmd () {print -Pn "\e]0;%~\a"}
        ;;
esac

safe_source $(dirname $(gem which colorls))/tab_complete.sh

safe_source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
safe_source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval $(thefuck --alias)

# autoload -U promptinit; promptinit
# prompt pure

eval $(starship init zsh)
