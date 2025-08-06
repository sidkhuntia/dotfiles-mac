DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_THEME="robbyrussell"

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
plugins=(git zsh-autosuggestions zsh-syntax-highlighting) 
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1
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
alias zshconfig="vim ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias refresh="source ~/.zshrc"
alias cddev="cd $HOME/Developer/personal"
alias cdlh="cd $HOME/Developer/lohum"
alias gobi="go build && go install"
alias go9="go1.19.10"
alias gacsm="git add . && gcsm"
alias gcd="git branch -d"
alias gcdf="git branch -D"
alias gcdr="git push origin --delete"
alias gfp="git fetch -p"
alias gcemp="git commit -s -S --allow-empty -m"
alias gpom="git push -u origin main"
alias c="clear"
alias cdd="builtin cd"
alias gcl= "git clone"
alias gco="git switch"
alias ytbest="yt-dlp -f 'bestvideo[height<=1440][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' -o '~/Downloads/media/yt-downloads/%(title)s.mp4' "
alias ytmax="yt-dlp -f 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b' -o '~/Downloads/media/yt-downloads/%(title)s.mp4' "
alias ytaudio="yt-dlp -x --audio-format mp3 --audio-quality 0 -o '~/Downloads/media/yt-downloads/%(title)s.mp3' "

alias lg="lazygit"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH=$HOME/.meteor:$PATH
export PATH="$(pwd)/bin:$PATH"




# Created by `pipx` on 2023-05-14 06:50:23
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/Downloads/kafka_2.13-3.4.0/bin"
export PATH=$PATH:$HOME/.spicetify
export PATH="/opt/homebrew/opt/cyrus-sasl/sbin:$PATH"

export GOPATH="$HOME/go"
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$GOPATH/bin

# Added by Amplify CLI binary installer
export PATH="$HOME/.amplify/bin:$PATH"
export PATH="$HOME/.ebcli-virtual-env/executables:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -z "$DISABLE_ZOXIDE" ] && eval "$(zoxide init --cmd cd zsh)"
eval PATH="$(bash --norc -ec 'IFS=:; paths=($PATH); 
for i in ${!paths[@]}; do 
if [[ ${paths[i]} == "''/Users/siddhartha.khuntialohum.com/.pyenv/shims''" ]]; then unset '\''paths[i]'\''; 
fi; done; 
echo "${paths[*]}"')"
export PATH="/Users/siddhartha.khuntialohum.com/.pyenv/shims:${PATH}"
eval "$(pyenv init --path)"

run_git_stash_checker() {
    local script_path="$HOME/Developer/personal/git_stash_check.sh"
    if [ -f "$script_path" ]; then
        bash "$script_path"
    fi
}

function cd() {
    __zoxide_z "$@"
    run_git_stash_checker
}


run_git_stash_checker

alias shstash=run_git_stash_checker

eval "$(fzf --zsh)"

function ghrepo() {
  local visibility="--private"
  # parse flags
  while [[ "$1" =~ ^- ]]; do
    case $1 in
      -u|--public) visibility="--public" ;;
      -h|--help)
        echo "Usage: ghrepo [-u|--public] <repo_name>"
        echo "Creates a private repo by default; use -u to make it public."
        return 0
        ;;
      *) 
        echo "Unknown option: $1"
        echo "Usage: ghrepo [-u|--public] <repo_name>"
        return 1
        ;;
    esac
    shift
  done

  local name=$1
  if [[ -z "$name" ]]; then
    echo "Usage: ghrepo [-u|--public] <repo_name>"
    return 1
  fi

  gh repo create "$name" $visibility --source=. --remote=origin
}

# pnpm
export PNPM_HOME="/Users/siddhartha.khuntialohum.com/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/siddhartha.khuntialohum.com/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/siddhartha.khuntialohum.com/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/siddhartha.khuntialohum.com/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/siddhartha.khuntialohum.com/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# bun completions
[ -s "/Users/siddhartha.khuntialohum.com/.bun/_bun" ] && source "/Users/siddhartha.khuntialohum.com/.bun/_bun"
