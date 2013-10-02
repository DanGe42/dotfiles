#!/bin/sh

ln -s $PWD/.vimrc ~/
mkdir -p ~/.vimtmp/backup
mkdir -p ~/.vimtmp/swp

git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
vim +BundleInstall +qall
