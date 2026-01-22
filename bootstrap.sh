#!/bin/sh

set -o errexit
set -o nounset

# Helper function to safely create symlinks
safe_ln() {
    src="$1"
    dest="$2"
    if [ -e "$dest" ]; then
        echo "WARNING: $dest already exists, skipping link from $src"
    else
        echo "ln -s $src $dest"
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
        echo "git clone $repo $dest"
        git clone "$repo" "$dest"
    fi
}

echo "=== Updating submodules ==="
git submodule init
git submodule update

echo "=== Setting up z script ==="
mkdir -p ~/bin
safe_ln "$PWD/bin/z/z.sh" ~/bin/z.sh
safe_ln "$PWD/bin/z/z.1" ~/bin/z.1

echo "=== Setting up tmux ==="
safe_clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
safe_ln "$PWD/dotfiles/tmux.conf" ~/.tmux.conf

echo "=== Setting up themes ==="
safe_ln "$PWD/themes" ~/.themes

echo "=== Setting up ZSH ==="
safe_clone https://github.com/tarjoilija/zgen ~/bin/zgen
safe_ln "$PWD/dotfiles/zshrc" ~/.zshrc
safe_ln "$PWD/dotfiles/aliases" ~/.aliases

echo "=== Setting up Git ==="
safe_ln "$PWD/dotfiles/gitconfig" ~/.gitconfig

echo "=== Setting up Vim and Neovim ==="
# This vimrc should work on systems with vim but without neovim
safe_ln "$PWD/dotfiles/vimrc" ~/.vimrc

# Neovim specific setup
mkdir -p ~/.config
safe_ln "$PWD/dotfiles/nvim" ~/.config/nvim
