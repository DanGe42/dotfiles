#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

# Update submodules first
git submodule init
git submodule update

# Set up z script
mkdir -p ~/bin
ln -s "$PWD"/bin/z/z.sh ~/bin
ln -s "$PWD"/bin/z/z.1 ~/bin

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -s "$PWD"/dotfiles/tmux.conf ~/.tmux.conf

ln -s "$PWD"/themes ~/.themes

# Set up ZSH
git clone git://github.com/tarjoilija/zgen ~/bin/zgen
ln -s "$PWD"/dotfiles/zshrc ~/.zshrc
ln -s "$PWD"/dotfiles/aliases ~/.aliases

# Set up Git
ln -s "$PWD"/dotfiles/gitconfig ~/.gitconfig

# Set up Vim
ln -s "$PWD"/dotfiles/vimrc ~/.vimrc
mkdir -p ~/.vimtmp/backup
mkdir -p ~/.vimtmp/swp
mkdir -p ~/.vim
# Set up Neovim
mkdir -p ~/.config
ln -s ~/.vim ~/.config/nvim
ln -s ~/.vimrc ~/.config/nvim/init.vim

# Install Python support for Neovim
if which pip2 2> /dev/null
then
    pip2 install --upgrade neovim || true
fi
if which pip3 2> /dev/null
then
    pip3 install --upgrade neovim || true
fi

# Set up dein.vim (vim plugin manager)
dein_tmp=$(mktemp -t "dein_installer")
curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > "$dein_tmp"
sh "$dein_tmp" ~/.vim/bundles
vim +"call dein#install()" +qall
