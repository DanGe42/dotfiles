#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

# Helper function to safely create symlinks
safe_ln() {
    src="$1"
    dest="$2"
    if [ -e "$dest" ]; then
        echo "WARNING: $dest already exists, skipping link from $src"
    else
        ln -s "$src" "$dest"
    fi
}

# Helper function to safely clone git repos
safe_clone() {
    repo="$1"
    dest="$2"
    if [ -e "$dest" ]; then
        echo "WARNING: $dest already exists, skipping clone of $repo"
    else
        git clone "$repo" "$dest"
    fi
}

# Update submodules first
git submodule init
git submodule update

# Set up z script
mkdir -p ~/bin
safe_ln "$PWD/bin/z/z.sh" ~/bin/z.sh
safe_ln "$PWD/bin/z/z.1" ~/bin/z.1

# Set up tmux
safe_clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
safe_ln "$PWD/dotfiles/tmux.conf" ~/.tmux.conf

safe_ln "$PWD/themes" ~/.themes

# Set up ZSH
safe_clone https://github.com/tarjoilija/zgen ~/bin/zgen
safe_ln "$PWD/dotfiles/zshrc" ~/.zshrc
safe_ln "$PWD/dotfiles/aliases" ~/.aliases

# Set up Git
safe_ln "$PWD/dotfiles/gitconfig" ~/.gitconfig

# Set up Vim
safe_ln "$PWD/dotfiles/vimrc" ~/.vimrc
mkdir -p ~/.vimtmp/backup
mkdir -p ~/.vimtmp/swp
mkdir -p ~/.vim
# Set up Neovim
mkdir -p ~/.config
safe_ln ~/.vim ~/.config/nvim
safe_ln ~/.vimrc ~/.config/nvim/init.vim

# Set up dein.vim (vim plugin manager)
if [ ! -e ~/.vim/bundles ]; then
    dein_tmp=$(mktemp -t "dein_installer")
    curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > "$dein_tmp"
    sh "$dein_tmp" ~/.vim/bundles
    vim +"call dein#install()" +qall
else
    echo "WARNING: ~/.vim/bundles already exists, skipping dein.vim setup"
fi
