# Added by ForgeCode installer
export PATH="$PATH:$HOME/.local/bin"
## Make Mac dock faster
# ---------------------
# defaults write com.apple.dock autohide-delay -int 0 ; defaults write com.apple.dock autohide-time-modifier -float 0.4 ; killall Dock
# ---------------------
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Activate mise
export MISE_GLOBAL_CONFIG_FILE="$HOME/.config/nix-darwin-config/config/mise/config.toml"
if command -v mise >/dev/null; then
  eval "$(mise activate zsh)"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
if [[ -d /run/current-system/sw/share/oh-my-zsh ]]; then
  export ZSH="/run/current-system/sw/share/oh-my-zsh"
  export ZSH_CUSTOM="/run/current-system/sw/share/oh-my-zsh-custom"
else
  export ZSH="$HOME/.oh-my-zsh"
fi

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
# ZSH_THEME="powerlevel10k/powerlevel10k"

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
zstyle ':omz:update' mode disabled  # disable automatic updates
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
plugins=(git rust zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting)

source "$ZSH/oh-my-zsh.sh"

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
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Create and activate venv python3
alias create_venv='python3 -m venv .venv && source .venv/bin/activate'

# Active venv python3 
alias activate_venv='source .venv/bin/activate'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# fzf configs 
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
# Auto-completion
# ---------------
if command -v fzf-share >/dev/null; then
  [[ $- == *i* ]] && source "$(fzf-share)/completion.zsh" 2> /dev/null
fi
# Key bindings
# ------------
if command -v fzf-share >/dev/null; then
  source "$(fzf-share)/key-bindings.zsh"
fi
# fzf shortcuts 
alias ff='fzf --preview="cat {}"'
alias ffn='nvim $(fzf --preview="cat {}")'

# Export go binaries
# export PATH=$PATH:$(go env GOPATH)/bin
# export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
# export LDFLAGS="-L/opt/homebrew/opt/libpq/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/libpq/include"

# export LDFLAGS="-L/opt/homebrew/opt/curl/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/curl/include"
#
# export PATH=$(brew --prefix llvm)/bin:$PATH
# export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"
# export LIBCLANG_PATH=$(brew --prefix llvm)/lib

# export PATH=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib:$PATH
# export LIBRARY_PATH="$LIBRARY_PATH:/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib"

# Load completitions from brew
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
  autoload -Uz compinit
  compinit
fi
# End

# Claude configs
export CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1
# export CLAUDE_CODE_EFFORT_LEVEL=max

if [ -z "$DISABLE_ZOXIDE" ]; then
    eval "$(zoxide init --cmd cd zsh)"
fi

# Codex config
export REASONING_EFFORT="xhigh"

export EDITOR="nvim"
export VISUAL="nvim"

zshrc() {
  "$EDITOR" "$HOME/.config/nix-darwin-config/dotfiles/.zshrc"
}

config() {
  "$EDITOR" "$HOME/.config/nix-darwin-config/"
}

# Function to switch GCP profiles with strict directory isolation
function gctx() {
  local profile_name=$1

  if [[ -z "$profile_name" ]]; then
    echo "Usage: gcp <profile_name>"
    echo "Current context: ${CLOUDSDK_CONFIG:-Default (Global)}"
    return 1
  fi

  # 1. Define the path. 
  # We use a 'profiles' subdirectory to avoid conflicts with system folders like 'logs'
  local profile_path="$HOME/.config/gcloud/profiles/$profile_name"

  # 2. Set the Environment Variable (This provides the isolation)
  export CLOUDSDK_CONFIG="$profile_path"

  # 3. User Feedback
  echo "✅ Switched Google Cloud context to: $profile_name"
  echo "📂 Config Source: $CLOUDSDK_CONFIG"

  # 4. Check if this profile is fresh/empty
  if [[ ! -f "$profile_path/application_default_credentials.json" ]]; then
    echo ""
    echo "⚠️  Warning: No ADC credentials found in this folder yet."
    echo "   If this is a new profile, please run:"
    echo "   $ gcloud auth login"
    echo "   $ gcloud auth application-default login"
  fi
}

alias cat='bat --paging=never'
alias ls='eza --icons=always'
alias t='eza --icons=always -T --no-symlinks'

# Nix
alias upgrade-nix='sudo determinate-nixd upgrade'

_nix_darwin_config_dir="$HOME/.config/nix-darwin-config"
_nix_darwin_flake_attr="MacBook-Pro-de-Henrique"

_nix_darwin_switch() {
  local config_dir="$1"
  local flake_attr="$2"

  sudo darwin-rebuild switch --flake "$config_dir#$flake_attr"
}

_nix_package_declared() {
  local pkg="$1"
  local flake="$2"

  awk -v pkg="$pkg" '
    {
      line = $0
      sub(/#.*/, "", line)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
      if (line == pkg) {
        found = 1
      }
    }
    END { exit found ? 0 : 1 }
  ' "$flake"
}

# Add a package to nix-darwin and rebuild
nix-add() {
  if [ -z "$1" ]; then
    echo "Usage: nix-add <package-name>"
    return 1
  fi

  local pkg="$1"
  local config_dir="$_nix_darwin_config_dir"
  local flake_attr="$_nix_darwin_flake_attr"
  local flake="$config_dir/flake.nix"

  # Verify the flake exists
  if [ ! -f "$flake" ]; then
    echo "Error: $flake not found"
    return 1
  fi

  # Validate against the same pinned nixpkgs used by this nix-darwin flake.
  echo "Checking that '$pkg' exists in this flake's nixpkgs..."
  if ! nix eval --raw "$config_dir#darwinConfigurations.$flake_attr.pkgs.$pkg.name" &>/dev/null; then
    echo "Error: package '$pkg' not found in this flake's nixpkgs"
    echo "Try searching: nix search nixpkgs $pkg"
    return 1
  fi

  # Check if it's already in the flake
  if _nix_package_declared "$pkg" "$flake"; then
    echo "'$pkg' is already declared in $flake"
    echo "Run nix-rebuild if you need to switch the current system generation."
    return 0
  fi

  local backup="${flake}.bak"
  local tmp
  tmp="$(mktemp)" || return 1

  cp "$flake" "$backup"

  # Insert the package before the closing bracket of environment.systemPackages.
  if ! awk -v pkg="$pkg" '
    /environment.systemPackages = with pkgs; \[/ {
      in_packages = 1
    }

    in_packages && /^[[:space:]]*\];[[:space:]]*$/ {
      print "            " pkg
      inserted = 1
      in_packages = 0
    }

    { print }

    END { exit inserted ? 0 : 1 }
  ' "$backup" > "$tmp"; then
    echo "Error: could not find environment.systemPackages in $flake"
    rm -f "$tmp"
    mv "$backup" "$flake"
    return 1
  fi

  mv "$tmp" "$flake"

  echo "Added '$pkg' to $flake. Rebuilding..."
  if _nix_darwin_switch "$config_dir" "$flake_attr"; then
    echo "✓ '$pkg' installed successfully"
    rm -f "$backup"
  else
    echo "✗ Rebuild failed. Restoring previous flake..."
    mv "$backup" "$flake"
    return 1
  fi
}

nix-remove() {
  if [ -z "$1" ]; then
    echo "Usage: nix-remove <package-name>"
    return 1
  fi

  local pkg="$1"
  local config_dir="$_nix_darwin_config_dir"
  local flake_attr="$_nix_darwin_flake_attr"
  local flake="$config_dir/flake.nix"

  if ! _nix_package_declared "$pkg" "$flake"; then
    echo "'$pkg' is not in $flake"
    return 1
  fi

  local backup="${flake}.bak"
  local tmp
  tmp="$(mktemp)" || return 1

  cp "$flake" "$backup"

  if ! awk -v pkg="$pkg" '
    {
      line = $0
      sub(/#.*/, "", line)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
      if (line == pkg) {
        removed = 1
        next
      }
      print
    }

    END { exit removed ? 0 : 1 }
  ' "$backup" > "$tmp"; then
    echo "Error: could not remove '$pkg' from $flake"
    rm -f "$tmp"
    mv "$backup" "$flake"
    return 1
  fi

  mv "$tmp" "$flake"

  echo "Removed '$pkg' from $flake. Rebuilding..."
  if _nix_darwin_switch "$config_dir" "$flake_attr"; then
    echo "✓ '$pkg' removed successfully"
    rm -f "$backup"
  else
    echo "✗ Rebuild failed. Restoring previous flake..."
    mv "$backup" "$flake"
    return 1
  fi
}

nix-rebuild() {
  _nix_darwin_switch "$_nix_darwin_config_dir" "$_nix_darwin_flake_attr"
}

# Local secrets and machine-specific config

if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi
