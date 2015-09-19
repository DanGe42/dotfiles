#!/bin/sh

set -eu

# Update submodules first
git submodule init
git submodule update

# Set up z script
mkdir -p ~/bin
ln -s $PWD/bin/z/z.sh ~/bin
ln -s $PWD/bin/z/z.1 ~/bin

ln -s $PWD/dotfiles/tmux.conf ~/.tmux.conf
ln -s $PWD/themes ~/.themes

# Set up ZSH
git clone git://github.com/tarjoilija/zgen ~/bin/zgen
ln -s $PWD/dotfiles/zshrc ~/.zshrc
ln -s $PWD/dotfiles/aliases ~/.aliases

# Set up Git
ln -s $PWD/dotfiles/gitconfig ~/.gitconfig

# Set up Vim
ln -s $PWD/dotfiles/vimrc ~/.vimrc
mkdir -p ~/.vimtmp/backup
mkdir -p ~/.vimtmp/swp

git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
vim +NeoBundleInstall +qall
