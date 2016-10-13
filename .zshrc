#!/usr/bin/env zsh

export MANPATH=/usr/local/share/man:$MANPATH

export TERM=xterm-256color

export LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

if [[ ! -z "$SSH_CLIENT" && -z "$TMUX" ]]; then
	tmux attach || tmux
fi

ZSH_THEME=kirb-powerlevel
DISABLE_AUTO_UPDATE=true
COMPLETION_WAITING_DOTS=true
ENABLE_CORRECTION=true
DEFAULT_USER=whatponi
plugins=(battery brew gpg-agent osx pod safe-paste ssh-agent tmux)

ZSH=$(dirname $0)/.oh-my-zsh

source $ZSH/oh-my-zsh.sh

has () {
	type "$1" >/dev/null 2>/dev/null
}

safe_source() {
	[[ -f "$1" ]] && source "$1"
}

export VISUAL='nano'
export EDITOR="$VISUAL"

# Used to set editor over SSH, only use if editor is non-standard
# [[ ! -z "$SSH_CLIENT" ]] && export VISUAL=nano && export EDITOR="$VISUAL"

export GOPATH=/usr/local/lib/go

if [[ "$SHELL" != "/usr/bin/zsh" ]] && has brew; then
	unalias run-help 2>/dev/null
	autoload run-help
	HELPDIR=/usr/local/share/zsh/help
fi

safe_source $(dirname $0)/.path
safe_source $(dirname $0)/.aliases
safe_source $(dirname $0)/.functions
safe_source $(dirname $0)/.extra
safe_source ~/.iterm2_shell_integration.zsh

safe_source /usr/local/share/zsh-syntax-highlightinh/zsh-syntax-highlighting.zsh
safe_source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

if has ruby && has gem; then
    PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi
