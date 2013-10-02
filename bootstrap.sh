#!/bin/sh

# Update submodules first
git submodule init
git submodule update

# Set up z script
mkdir -p ~/bin
ln -s $PWD/bin/z/z.sh ~/bin
ln -s $PWD/bin/z/z.1 ~/bin

ln -s $PWD/.tmux.conf ~/

# Set up Vim
setup/vim.sh

# Set up Git
setup/git.sh

# Set up ZSH
setup/zsh.sh