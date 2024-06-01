# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Add the openssl dir for DDS-Security
# if you are using ZSH, then replace '.bashrc' with '.zshrc'
#echo "export OPENSSL_ROOT_DIR=$(brew --prefix openssl)" >> ~/.zshrc

# Add the Qt directory to the PATH and CMAKE_PREFIX_PATH
export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:/usr/local/opt/qt@5
export PATH=$PATH:/usr/local/opt/qt@5/bin

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Path to GPT3 configuration
export PATH=~/.bin:$PATH

# Path to Python3
#export PATH="/Library/Frameworks/Python.framework/Versions/3.10/bin/:${PATH}"

# Path to flutter
export PATH=~/documents/development/flutter/bin:$PATH

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="powerlevel10k/powerlevel10k"
#ZSH_THEME="ys"
#
# starship theme
eval "$(starship init zsh)"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git rust zsh-nvm asdf)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshconfig="nvim ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# Plugin history-search-multi-word loaded with investigating.
zinit load zdharma-continuum/history-search-multi-word

# Two regular plugins loaded without investigating.
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting

# Snippet
zinit snippet https://gist.githubusercontent.com/hightemp/5071909/raw/

export OPENSSL_ROOT_DIR=/opt/homebrew/opt/openssl@3

alias lvim="/Users/henriquematias/.local/bin/lvim"

export PATH="/opt/homebrew/Cellar/qt@5/5.15.8_2/bin:$PATH"
export PATH="/opt/homebrew/Cellar/pyqt@5/5.15.7_2/bin:$PATH"

export OPENSSL_ROOT_DIR=/opt/homebrew/opt/openssl@3

# Open code folder
alias cdc='cd ~/Documents/GitHub/ && ls'

# Create and activate venv python3
alias create_venv='python3 -m venv .venv && source .venv/bin/activate'

# Active venv python3 
alias activate_venv='source .venv/bin/activate'

# Docker alias
alias docker-clean='docker system prune -a'

# JetBrains IDE
# PyCharm
alias codepy='open -a "PyCharm"'
# WebStorm
alias ws='open -a "WebStorm"'
# CLion
alias clion='open -na "CLion.app" --args "$@"'
# Rust Rover
alias rr='open -na "RustRover.app" --args "$@"'

# bun completions
[ -s "/Users/henriquematias/.bun/_bun" ] && source "/Users/henriquematias/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export OPENSSL_ROOT_DIR=/opt/homebrew/opt/openssl@3

export CXXFLAGS="-std=c++20"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
#__conda_setup="$('/Users/henriquematias/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
#if [ $? -eq 0 ]; then
#    eval "$__conda_setup"
#else
#    if [ -f "/Users/henriquematias/anaconda3/etc/profile.d/conda.sh" ]; then
#        . "/Users/henriquematias/anaconda3/etc/profile.d/conda.sh"
#    else
#        export PATH="/Users/henriquematias/anaconda3/bin:$PATH"
#    fi
#fi
#unset __conda_setup

#if [ -f "/Users/henriquematias/anaconda3/etc/profile.d/mamba.sh" ]; then
#    . "/Users/henriquematias/anaconda3/etc/profile.d/mamba.sh"
#fi
# <<< conda initialize <<<

#Inicio do teste
function activate_conda() {
    __conda_setup="$('/Users/henriquematias/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/Users/henriquematias/anaconda3/etc/profile.d/conda.sh" ]; then
            . "/Users/henriquematias/anaconda3/etc/profile.d/conda.sh"
        else
            export PATH="/Users/henriquematias/anaconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
    if [ -f "/Users/henriquematias/anaconda3/etc/profile.d/mamba.sh" ]; then
        . "/Users/henriquematias/anaconda3/etc/profile.d/mamba.sh"
    fi
}

alias useconda='activate_conda'
# Fim do teste

#conda deactivate

export FNMPMAC=true

export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export ROS_DOMAIN_ID=50
export TURTLEBOT3_MODEL=burger

export OPENSSL_ROOT_DIR=/opt/homebrew/opt/openssl@3

unalias go

export PATH=$PATH:$(go env GOPATH)/bin

alias g='go run main.go'

eval "$(zoxide init --cmd cd zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# alias t='tree'
function t() {
  if [[ $1 =~ '^[0-9]+$' ]]; then
    tree -L "$1"
  else
    tree "$@"
  fi
}

alias n='nvim'
alias nconfig='nvim ~/.config/nvim'
