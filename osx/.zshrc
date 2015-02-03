# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="danielge"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(brew bundler extract gem node npm nyan pip \
    rvm rails zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh
unsetopt correct_all

source ~/bin/z.sh

# Start an HTTP server from a directory, optionally specifying the port
function server() {
    local port="${1:-8000}"
    ( sleep 2; open "http://localhost:${port}/" ) &
    python -m SimpleHTTPServer "$port"
}

source $HOME/.aliases

# Customize to your needs...
export EC2_HOME="$HOME/bin/ec2/"
export EC2_CERT="$HOME/.ec2/cert.pem"
export EC2_PRIVATE_KEY="$HOME/.ec2/access.pem"
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$PATH:$EC2_HOME/bin"

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
export PATH="$PATH:$HOME/.cabal/bin"
