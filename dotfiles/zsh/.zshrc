#==============================================================================#
#       System Enviroment Exports
#==============================================================================#
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/.local/scripts/:$PATH

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Go enviroment variable
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=/usr/local/go/bin:$PATH
export PATH=$HOME/go/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Trick for TMUX
# export TERM=screen-256color
export TERM=xterm-256color

# Setting my default $EDITOR
if command -v /usr/bin/nvim &> /dev/null
then
    export EDITOR='/usr/bin/nvim'
    alias nvrc='$EDITOR ~/.config/nvim/init.lua'
elif command -v /usr/bin/vim &> /dev/null
then
    export EDITOR='/usr/bin/vim'
else
    export EDITOR='/usr/bin/vi'
fi

# Completion Options
# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Commands autocorrection
ENABLE_CORRECTION="true"

# Setting the theme
ZSH_THEME="spaceship"

# Dots as completion lags
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

#==============================================================================#
#       FZF Command-line binds
#==============================================================================#

if [[ ! "$PATH" == */home/hugo/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/hugo/.fzf/bin"
fi

source <(fzf --zsh)
bindkey '^r' fzf-history-widget
# export FZF_CTRL_T_OPTS="
#   --walker-skip .git,node_modules,target
#   --preview 'bat -n --color=always {}'
#   --bind 'ctrl-/:change-preview-window(down|hidden|)'"
#
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

#==============================================================================#
#       Spaceship Prompt Config
#==============================================================================#
SPACESHIP_PROMPT_ORDER=(
    user
    host
    dir
    git
    venv
    python
    php
    golang
    lua
    exec_time
    line_sep
    exit_code
    char
)

SPACESHIP_USER_SHOW=always
SPACESHIP_EXIT_CODE_SHOW=true
SPACESHIP_EXIT_CODE_SYMBOL='✘ '
SPACESHIP_CHAR_SUFFIX=' '

#==============================================================================#
#       Oh My Zsh Configs
#==============================================================================#
plugins=(git zsh-autosuggestions ssh-agent)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff"

source $ZSH/oh-my-zsh.sh

autoload -U compinit && compinit

#==============================================================================#
#       Alises
#==============================================================================#
alias drx="find /home/ -type d -name dotfiles -exec /usr/bin/nvim {} \;"
alias zshrc="nvim ~/.zshrc"
alias trc="nvim ~/.tmux.conf"

alias gs="git status"

alias vim="nvim"

alias sz="source ~/.zshrc"
alias st="source ~/.tmux.conf"

alias lg="lazygit"

alias explorer="explorer.exe ."

alias tmux="TERM=xterm-256color tmux"

alias start="tmux new -s start"

#==============================================================================#
#       Keybinds
#==============================================================================#
bindkey '^y' autosuggest-accept
bindkey '^ ' autosuggest-fetch
bindkey '^r' fzf-history-widget
1
#==============================================================================#
#       Functions
#==============================================================================#

ex ()
{
    if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
    else
    echo "'$1' is not a valid file"
    fi
}


activate()
{
    if [[ -f $PWD/.venv/bin/activate ]]; then
        source $PWD/.venv/bin/activate
        echo $(which python3) >&2
    elif [[ -f $PWD/venv/bin/activate ]]; then
        source $PWD/venv/bin/activate
        echo $(which python3) >&2
    else
        echo "não existe ambiente python" >&2
    fi
}
