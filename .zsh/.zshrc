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

# activate mise-en-place
if (( ${+commands[mise]} )); then
  eval "$(mise activate zsh)"
  # make plugin commands available for following completion checks,
  # see https://mise.jdx.dev/dev-tools/shims.html#zshrc-bashrc-files
  eval "$(mise hook-env -s zsh)"
fi

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
zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands

# enable Shift+Tab for reverse search: https://unix.stackexchange.com/a/84869
zmodload zsh/complist
bindkey -M menuselect '^[[Z' reverse-menu-complete

# shortcut for editing command in vim
autoload edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# undo last expansion
bindkey '^z' undo

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

# change default zimfw git prefix
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

  # fish-like auto expand aliases
  # zgenom load olets/zsh-abbr

  zgenom load zimfw/git  # https://github.com/zimfw/git

  # Ohmyzsh cherry-picks; base library not necessarily required in all cases!
  # zgenom ohmyzsh
  zgenom ohmyzsh plugins/kubectl    # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/kubectl
  zgenom ohmyzsh plugins/aliases    # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/aliases
  zgenom ohmyzsh plugins/sudo       # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/sudo
  zgenom ohmyzsh plugins/dirhistory # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dirhistory
  zgenom ohmyzsh plugins/gpg-agent  # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/gpg-agent

  # save all to init script
  zgenom save
  # Compile your zsh files
  zgenom compile $ZDOTDIR
fi


#---------- NAVIGATION --------------------------------------------------------

# TODO: check autoload zkbd ; --> zkbd bindkey  "${key[Home]}"

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
export ZSHZ_NO_RESOLVE_SYMLINKS=1

#---------- FZF ---------------------------------------------------------------

# source fuzzy finder config & keybindings, https://wiki.archlinux.org/title/Fzf#Zsh
fzf1="/usr/share/fzf/completion.zsh"
fzf2="/usr/share/fzf/key-bindings.zsh"
if [[ -f $fzf1 ]] || [[ -e $fzf1 ]]; then
  . "$fzf1"
  . "$fzf2"
fi

# use fd (https://github.com/sharkdp/fd) instead of the default find
# https://github.com/junegunn/fzf#settings
_fzf_compgen_path() {
  fd --no-ignore --hidden --follow --exclude ".git" . "$1"
}
_fzf_compgen_dir() {
  fd --no-ignore --type d --hidden --follow --exclude ".git" . "$1"
}

# add default options for fzf
export FZF_DEFAULT_OPTS="
  --height 40%
  --layout=reverse
  --border
  --bind='?:toggle-preview'
  --preview-window hidden"

# add options for fzf file search
export FZF_CTRL_T_OPTS="--preview 'bat --style=plain --color=always {}'"

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

#---------- FURTHER ZSH SETTINGS ----------------------------------------------

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# enable comments with # in interactive shells
setopt INTERACTIVE_COMMENTS
# correct commands and options
setopt CORRECT
setopt CORRECT_ALL
# cd by typing the path
setopt AUTOCD
# enable dir stack with cd -<TAB>
setopt AUTO_PUSHD
# exchange meaning of -/+ in `cd -N`
setopt PUSHD_MINUS
# prevent overwriting existing files
setopt NO_CLOBBER
# treat the #, ~ and ^ characters as part of patterns for filename generation
setopt EXTENDED_GLOB
# only throw error when ALL file globs do not match anything
setopt CSH_NULL_GLOB
# disable control flow via ^S and ^Q
setopt NO_FLOW_CONTROL
# ensure autocompletion for aliases is disabled (if option set by e.g. ohmyzsh)
unsetopt COMPLETE_ALIASES

#---------- CUSTOM WIDGETS ----------------------------------------------------

# NOTE: find escape codes through plain `cat` + key-combo

# taken from zimfw
widget-double_dot_expand() {
  # Expand .. at the beginning, after space, or after any of ! " & ' / ; < > |
  if [[ ${LBUFFER} == (|*[[:space:]!\"\&\'/\;\<\>|]).. ]]; then
    LBUFFER+='/..'
  else
    LBUFFER+='.'
  fi
}
zle -N widget-double_dot_expand
bindkey '.' widget-double_dot_expand
bindkey -M isearch '.' self-insert

# toggle comment
widget-toggle_comment() {
  if [[ "${BUFFER}" =~ "^#" ]]; then
    BUFFER=$(echo ${BUFFER} | sed -e 's/^#[[:space:]]*//')
  else
    BUFFER="# ${BUFFER}"
  fi
  zle redisplay
}
zle -N widget-toggle_comment
bindkey "^_^_" widget-toggle_comment

# show inline alias definition, see https://superuser.com/a/894379
widget-inline_alias() {
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
zle -N widget-inline_alias
bindkey "^G" widget-inline_alias

# fuzzy search aliases
widget-fzf_alias() {
  # emulate -L zsh
  local CURRENT_WORD="${LBUFFER/* /}${RBUFFER/ */}"
  zle backward-word
  RBUFFER="$(alias | grep -i "^$CURRENT_WORD" | column -ts '=' | fzf | cut -f1 -d ' ' )"
  zle forward-word
  zle redisplay
}
zle -N widget-fzf_alias
bindkey "^F" widget-fzf_alias

# copy terminal buffer to clipboard
widget-copy_command_to_clipboard() {
  print -rn $BUFFER | wl-copy -o
}
zle -N widget-copy_command_to_clipboard
bindkey "^[c" widget-copy_command_to_clipboard

# cut terminal buffer to clipboard
widget-kill_command_to_clipboard() {
  zle kill-buffer
  print -rn $CUTBUFFER | wl-copy -o
}
zle -N widget-kill_command_to_clipboard
bindkey "^[c^[c" widget-kill_command_to_clipboard

# edit file with fzf selection; see https://github.com/junegunn/fzf/issues/3650
widget-fzf_edit_file() {
  fzf --bind 'enter:become(nvim {})' <"${TTY}"
  zle reset-prompt
}
zle -N widget-fzf_edit_file
bindkey "^v" widget-fzf_edit_file

# z with fzf selection
widget-fzf_z() {
  eval cd "$(z | tac | fzf | awk '{print $2}')"
  zle kill-buffer
  zle accept-line
  # NOTE: if you prefer to have cd cmds in history do instead:
  # (this is also how fzf is doing it for ALT+C, check /usr/share/fzf/key-bindings.zsh)
  # local dir="$(z | tac | fzf | awk '{print $2}')"
  # BUFFER="cd -- ${dir}"
  # TODO: below really required?
  # local ret=$?
  # unset dir
  # zle reset-prompt
  # return $ret
}
zle -N widget-fzf_z
bindkey "^z" widget-fzf_z


#---------- MISC --------------------------------------------------------------

# source alias file
source "${ZDOTDIR}/.aliases"

# add local bin folder to path
export PATH=${HOME}/.local/bin:${PATH}

# add go package binaries to $PATH
if [ ${+commands[go]} ]; then
  export GOPATH=${HOME}/.go
  export PATH=${GOPATH}/bin:${PATH}
fi

# add rust package binaries to $PATH
if [ ${+commands[cargo]} ]; then
  export CARGOPATH=${HOME}/.cargo
  export PATH=${CARGOPATH}/bin:${PATH}
fi

# add krew binaries to path
(( ${+commands[krew]} )) && export PATH=${KREW_ROOT:-$HOME/.krew}/bin:${PATH}

# include community/broot
(( ${+commands[broot]} )) && source "${HOME}"/.config/broot/launcher/bash/br

# zsh-native autocompletions
(( ${+commands[kubectl]} )) && source <(kubectl completion zsh)
(( ${+commands[minikube]} )) && source <(minikube completion zsh)
(( ${+commands[k3d]} )) && source <(k3d completion zsh)
(( ${+commands[istioctl]} )) && source <(istioctl completion zsh)
(( ${+commands[kubeone]} )) && source <(kubeone completion zsh)
(( ${+commands[argocd]} )) && source <(argocd completion zsh)
(( ${+commands[helm]} )) && source <(helm completion zsh)
(( ${+commands[switcher]} )) && source <(switcher completion zsh)

# google cloud CLI binary & completion for AUR package
if pacman -Qi google-cloud-cli &> /dev/null; then
  source /etc/profile.d/google-cloud-cli.sh
  source ${GOOGLE_CLOUD_SDK_HOME}/completion.zsh.inc
fi

# autocomplete via bash
autoload bashcompinit && bashcompinit
complete -C "$(which aws_completer)" aws
complete -o nospace -C "$(which terraform)" terraform

# azure CLI autocomplete (bash)
if pacman -Qi azure-cli &> /dev/null; then
  source /usr/share/bash-completion/completions/az
fi

# autocomplete 'the proper way' with files from /usr/share/zsh/site-functions/*
# see: https://github.com/gopasspw/gopass/blob/master/docs/setup.md
# and: https://github.com/gopasspw/gopass/issues/585

# let gpg not encrypt anonymously, otherwise OpenKeyChain / APS won't work
# https://github.com/android-password-store/Android-Password-Store/issues/173
# https://github.com/drduh/YubiKey-Guide/issues/152
export GOPASS_GPG_OPTS="--no-throw-keyids"

# set editor for crontab etc.
export VISUAL="nvim"
export EDITOR=$VISUAL
export TERMINAL=kitty
