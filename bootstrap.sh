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

# Setup functions for each component
setup_z() {
    echo "=== Setting up z script ==="
    mkdir -p ~/bin
    safe_ln "$PWD/bin/z/z.sh" ~/bin/z.sh
    safe_ln "$PWD/bin/z/z.1" ~/bin/z.1
}

setup_tmux() {
    echo "=== Setting up tmux ==="
    safe_clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    safe_ln "$PWD/dotfiles/tmux.conf" ~/.tmux.conf
}

setup_themes() {
    echo "=== Setting up themes ==="
    safe_ln "$PWD/themes" ~/.themes
}

setup_zsh() {
    echo "=== Setting up ZSH ==="
    safe_clone https://github.com/tarjoilija/zgen ~/bin/zgen
    safe_ln "$PWD/dotfiles/zshrc" ~/.zshrc
    safe_ln "$PWD/dotfiles/aliases" ~/.aliases
}

setup_git() {
    echo "=== Setting up Git ==="
    safe_ln "$PWD/dotfiles/gitconfig" ~/.gitconfig
}

setup_vim() {
    echo "=== Setting up Vim and Neovim ==="
    # This vimrc should work on systems with vim but without neovim
    safe_ln "$PWD/dotfiles/vimrc" ~/.vimrc

    # Neovim specific setup
    mkdir -p ~/.config
    safe_ln "$PWD/dotfiles/nvim" ~/.config/nvim
}

# Always update submodules first
echo "Initializing and updating submodules first..."
git submodule init
git submodule update

# Parse subcommands
if [ $# -eq 0 ] || [ "$1" = "all" ]; then
    # Run all setup functions
    setup_z
    setup_tmux
    setup_themes
    setup_zsh
    setup_git
    setup_vim
else
    # Run specific setup function(s)
    for cmd in "$@"; do
        case "$cmd" in
            z)
                setup_z
                ;;
            tmux)
                setup_tmux
                ;;
            themes)
                setup_themes
                ;;
            zsh)
                setup_zsh
                ;;
            git)
                setup_git
                ;;
            vim)
                setup_vim
                ;;
            *)
                echo "Unknown subcommand: $cmd"
                echo "Available subcommands: z, tmux, themes, zsh, git, vim, all"
                exit 1
                ;;
        esac
    done
fi
