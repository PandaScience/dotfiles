# if ZDOTDIR not set, no ~/.zshenv is in place and hence use $HOME
: "${ZDOTDIR:=${HOME}}"

#---------- PROMPT ------------------------------------------------------------

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
#
# include direnv as described here: https://github.com/romkatv/powerlevel10k#how-do-i-initialize-direnv-when-using-instant-prompt
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"

# To customize prompt, run `p10k configure` or edit ~/.zsh/.p10k.zsh.
[[ ! -f ~/.zsh/.p10k.zsh ]] || source ~/.zsh/.p10k.zsh


# Completion menu modifications
# https://thevaluable.dev/zsh-completion-guide-examples/
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' menu select
# zstyle ':completion:*' menu search select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# enable Shift+Tab for reverse search: https://unix.stackexchange.com/a/84869
zmodload zsh/complist
bindkey -M menuselect '^[[Z' reverse-menu-complete

# shortcut for editing command in vim
autoload edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line


#---------- PLUGINS -----------------------------------------------------------

# required for some ohmyzsh plugins like kubectl
: "${ZSH_CACHE_DIR:=${ZDOTDIR}/.cache}"
[[ ! -d "${ZSH_CACHE_DIR}" ]] && mkdir ${ZSH_CACHE_DIR}

# https://github.com/jandamm/zgenom
if [[ ! -f "${ZDOTDIR}/.zgenom/zgenom.zsh" ]]; then
  git clone https://github.com/jandamm/zgenom.git "${ZDOTDIR}/.zgenom"
fi
source "${ZDOTDIR}/.zgenom/zgenom.zsh"

zgenom autoupdate

ZGEN_RESET_ON_CHANGE=("${ZDOTDIR}/.zshrc")

zstyle ':zim:git' aliases-prefix 'g'

# load plugins
if ! zgenom saved; then
  echo "Creating a zgenom save"

  # in case plugins already require compdef to be available
  zgenom compdef

  # github plugins
  zgenom load romkatv/powerlevel10k powerlevel10k
  zgenom load zsh-users/zsh-autosuggestions
  zgenom load zsh-users/zsh-completions
  # zgenom load zdharma-continuum/fast-syntax-highlighting  # BUG? comment identified as unknown-token
  zgenom load zsh-users/zsh-syntax-highlighting
  zgenom load zsh-users/zsh-history-substring-search  # load after syntax highlighter!
  # zgenom load zdharma-continuum/history-search-multi-word
  zgenom load agkozak/zsh-z
  zgenom load dannyzen/cf-zsh-autocomplete-plugin.git

  zgenom load https://github.com/zimfw/git  # https://github.com/zimfw/git

  # Ohmyzsh cherry-picks; base library not necessarily required in all cases!
  # zgenom ohmyzsh
  zgenom ohmyzsh plugins/kubectl  # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/kubectl
  zgenom ohmyzsh plugins/aliases  # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/aliases
  zgenom ohmyzsh plugins/sudo     # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/sudo
  zgenom ohmyzsh plugins/dirhistory # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dirhistory

  # save all to init script
  zgenom save
  # Compile your zsh files
  zgenom compile $ZDOTDIR
fi


#---------- NAVIGATION --------------------------------------------------------

# TODO check autoload zkbd ; --> zkbd bindkey  "${key[Home]}"

# find keycodes with `cat -v`: `[[D = LEFT, `[[C = RIGHT, `[[A = UP `[[B = DOWN
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# CTRL+LEFT/RIGHT
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# HOME/END/DEL
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[3~"  delete-char


#---------- ZSH-Z -------------------------------------------------------------

export ZSHZ_TILDE=1
export ZSHZ_CASE=smart
export ZSHZ_TRAILING_SLASH=1
export ZSHZ_UNCOMMON=1


#---------- FZF ---------------------------------------------------------------

# source fuzzy finder config & keybindings, https://wiki.archlinux.org/title/Fzf#Zsh
fzf1="/usr/share/fzf/completion.zsh"
fzf2="/usr/share/fzf/key-bindings.zsh"
if [[ -f $fzf1 ]] || [[ -e $fzf1 ]]; then
	. "$fzf1"
	. "$fzf2"
fi

# https://github.com/junegunn/fzf#settings
#
# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --no-ignore --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --no-ignore --type d --hidden --follow --exclude ".git" . "$1"
}

# add default options for fzf
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --bind='?:toggle-preview' --preview 'bat --style=plain --color=always {}' --preview-window hidden"


#---------- HISTORY -----------------------------------------------------------

# https://askubuntu.com/questions/23630/how-do-you-share-history-between-terminals-in-zsh
HISTFILE="$HOME/.zsh/.zhistory"
HISTSIZE=10000000
SAVEHIST=$HISTSIZE
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
# setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions. DO NOT set INC_APPEND_HISTORY simultaneously.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
# setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
# setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

# ensure autocompletion for aliases is disabled (if option set by e.g. ohmyzsh)
unsetopt completealiases


#---------- FURTHER ZSH SETTINGS ----------------------------------------------

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# enable comments with # in interactive shells
setopt INTERACTIVE_COMMENTS
# error on unmatched quotes in command (-> no multiline commands!)
# setopt CSH_JUNKIE_QUOTES
# correct commands and options
setopt CORRECT
setopt CORRECT_ALL
# cd by typing the path
setopt AUTOCD
# enable dir stack with cd -<TAB>
setopt AUTO_PUSHD
# exchange meaning of -/+
setopt PUSHD_MINUS
# prevent overwriting existing files
setopt NO_CLOBBER
# no special treatment for file names with a leading dot
# setopt GLOB_DOTS
# require an extra TAB press to open the completion menu
# setopt NO_AUTO_MENU

# taken from zimfw
double-dot-expand() {
  # Expand .. at the beginning, after space, or after any of ! " & ' / ; < > |
  if [[ ${LBUFFER} == (|*[[:space:]!\"\&\'/\;\<\>|]).. ]]; then
    LBUFFER+='/..'
  else
    LBUFFER+='.'
  fi
}
zle -N double-dot-expand
bindkey '.' double-dot-expand
bindkey -M isearch '.' self-insert


#---------- CUSTOM WIDGETS ----------------------------------------------------

# show alias definition, see https://superuser.com/a/894379
expand_alias() {
  emulate -L zsh
  local CURRENT_WORD="${LBUFFER/* /}${RBUFFER/ */}"
  local ALIAS_FULL="$(alias -- "$CURRENT_WORD")"
  local ALIAS_RHS="${${ALIAS_FULL#*\'}%\'}"
  if [[ "$RBUFFER" =~ "  #" ]]; then
    RBUFFER="${RBUFFER%   #*}"
  elif [[ ! -z "$ALIAS_RHS" ]]; then
    RBUFFER="${RBUFFER}   # ${ALIAS_RHS}"
    # apply syntax highlighting to new buffer
    zle redisplay
  fi
}
# create widget from function and bind key
zle -N expand_alias
bindkey "^G" expand_alias

# copy terminal buffer to clipboard
copy_command_to_clipboard() {
  print -rn $BUFFER | xclip -i
}
zle -N copy_command_to_clipboard
bindkey "^[c" copy_command_to_clipboard

# cut terminal buffer to clipboard
kill_command_to_clipboard() {
  zle kill-buffer
  print -rn $CUTBUFFER | xclip -i
}
zle -N kill_command_to_clipboard
bindkey "^[c^[c" kill_command_to_clipboard


#---------- MISC --------------------------------------------------------------

# source alias file
source "${ZDOTDIR}/.aliases"

# --> SSH agent is handeled by systemd user (~/.config/systemd/user/ssh-agent.service)
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

export PATH=/home/rene/.local/bin:${PATH}
export PATH=/home/rene/bin:${PATH}

export GOPATH=${HOME}/.go
export PATH=${GOPATH}/bin:${PATH}

# include community/broot
source /home/rene/.config/broot/launcher/bash/br

# autocomplete kubectl
# source <(kubectl completion zsh)   # done by ohmyzsh plugin
source <(minikube completion zsh)

# autocomplete via bash
autoload bashcompinit && bashcompinit
complete -C "$(which aws_completer)" aws
complete -o nospace -C "$(which terraform)" terraform

# autocomplete 'the proper way' with files from /usr/share/zsh/site-functions/*
# see: https://github.com/gopasspw/gopass/blob/master/docs/setup.md
# and: https://github.com/gopasspw/gopass/issues/585
#
# gopass completion zsh > ~/_gopass
# sudo mv ~/_gopass /usr/share/zsh/site-functions/_gopass
# rm -i ${ZDOTDIR:-${HOME:?No ZDOTDIR or HOME}}/.zcompdump && compinit


# set editor for crontab etc.
export VISUAL="nvim"
export EDITOR=$VISUAL
export TERMINAL=kitty
