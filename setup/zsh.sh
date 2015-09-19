#!/bin/sh

curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
ln -s $PWD/themes/danielge.zsh-theme ~/.oh-my-zsh/themes/
ln -s $PWD/dotfiles/osx/zshrc ~/.zshrc
