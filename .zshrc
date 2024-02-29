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

safe_source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
safe_source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
safe_source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

if has thefuck; then
    eval $(thefuck --alias)
fi

autoload -U promptinit; promptinit
prompt pure

# if has starship; then
#     eval "$(starship init zsh)"
# fi

## https://github.com/llimllib/personal_code/blob/0e1034f13b31f8357c399d3159867601869e23de/homedir/.zshrc
# # set git up for prompt
# # https://git-scm.com/book/en/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-Zsh
# autoload -Uz vcs_info
# precmd_vcs_info() { vcs_info }
# precmd_functions+=( precmd_vcs_info )
# setopt prompt_subst
# # left version
# # zstyle ':vcs_info:git:*' formats '%K{yellow}%F{black}  %b %F{yellow}'
# # right version
# zstyle ':vcs_info:git:*' formats '%F{yellow}%F{black}%K{yellow}  %b %F{yellow}'

# # fancy hand-made powerline-style prompt. The trick is to switch the foreground
# # color of the arrow to the background color of the preceding section, and the
# # background color of the arrow to the background of the following section
# #
# # Here's a printf that may help demonstrate the effect:
# # printf "%b%bhome\xee\x82\xb1some-branch%b\n" "\e[30m" "\e[44m" "\e[0m"
# # however, we can't use those same sorts of escapes in a PROMPT, so we use
# # zsh's instead
# #
# # The %(5~|...) thing shortens the path when you're deep in a tree to:
# # `first segment/.../last/three/segments`, otherwise displays four segments
# # https://unix.stackexchange.com/a/273567
# #
# # https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
# #
# function makeprompt() {
#     local prompt=''

#     # status of last command. Green check if success, Red code if failure
#     prompt+="%(?.%K{green}%F{black}√ %F{green}.%K{red}%F{black}%? %F{red})"

#     # machine name in blue
#     prompt+="%K{blue}%F{black}  %m %F{blue}"

#     # current directory, limited to 4 segments, in green
#     prompt+="%K{green}%F{black}   %(5~|%-1~/…/%3~|%4~) %F{green}"

#     # prompt+='${vcs_info_msg_0_}'

#     # reset colors
#     LF=$'\n'
#     prompt+="%k%f ${LF}$ "

#     echo "$PROMPT"
# }

# # to debug:
# # echo "$(makeprompt)"
# export PS1="$(makeprompt)"

# # The right prompt should be on the same line as the first line of the left
# # prompt. To do so, there is just a quite ugly workaround: Before zsh draws
# # the RPROMPT, we advise it, to go one line up. At the end of RPROMPT, we
# # advise it to go one line down. See:
# # http://superuser.com/questions/357107/zsh-right-justify-in-ps1
# local RPROMPT_PREFIX='%{'$'\e[1A''%}' # one line up
# local RPROMPT_SUFFIX='%{'$'\e[1B''%}' # one line down

# # show the time on the right
# # export RPROMPT='%F{blue}%t'
# # with git branch (currently moved to left)
# export RPROMPT='${RPROMPT_PREFIX}${vcs_info_msg_0_}%F{magenta}%F{black}%K{magenta}%t${RPROMPT_SUFFIX}'
# #export RPROMPT="${RPROMPT_PREFIX}%F{magenta}%F{black}%K{magenta}%t${RPROMPT_SUFFIX}"

# # remove the useless space at the right of rprompt
# # https://superuser.com/a/726509/55099
# export ZLE_RPROMPT_INDENT=0
