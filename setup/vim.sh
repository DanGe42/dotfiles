#!/bin/sh

ln -s $PWD/dotfiles/vimrc ~/.vimrc
mkdir -p ~/.vimtmp/backup
mkdir -p ~/.vimtmp/swp

git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
vim +BundleInstall +qall
