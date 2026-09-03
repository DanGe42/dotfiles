# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repo, expected to live at `~/dotfiles`. Configs are kept here and **symlinked** into their canonical `$HOME` locations by `bootstrap.sh`. Editing a file in this repo edits the live config (via the symlink); editing `~/.zshrc` etc. directly would diverge from the repo, so always edit the source files under `dotfiles/`.

## Bootstrap

`bootstrap.sh <home|work> [subcommand...]` creates the symlinks and clones dependencies.

- First arg `home` or `work` is **required** — it selects which zshrc gets linked (`dotfiles/zshrc` vs `dotfiles/work/square/zshrc`).
- Subcommands: `z`, `tmux`, `themes`, `zsh`, `git`, `vim`, `all`. No subcommand (or `all`) runs everything.
- It runs `git submodule init && git submodule update` first, then symlinks. `safe_ln`/`safe_clone` skip targets that already exist (printing a WARNING) rather than overwriting — so to re-link a changed path you must remove the existing symlink first.

Symlink map (source → target): `dotfiles/zshrc`→`~/.zshrc`, `dotfiles/nvim`→`~/.config/nvim`, `dotfiles/vimrc`→`~/.vimrc`, `dotfiles/gitconfig`→`~/.gitconfig`, `dotfiles/aliases`→`~/.aliases`, `dotfiles/p10k.zsh`→`~/.p10k.zsh`, `dotfiles/tmux.conf`→`~/.tmux.conf`, `themes`→`~/.themes`, `bin/z/z.sh`→`~/bin/z.sh`.

## Home vs. work split

The work zshrc (`dotfiles/work/square/zshrc`) **sources** the universal `dotfiles/zshrc` and then layers Square-specific setup on top. So shared shell config belongs in `dotfiles/zshrc`; only work-specific bits go in the work file. The `home` zshrc is just `dotfiles/zshrc` directly.

## External dependencies (not in repo, must be installed separately)

The zshrc sources these by absolute path and will error if missing:
- `powerlevel10k`, `zsh-syntax-highlighting` (via Homebrew at `/opt/homebrew/...`)
- `zgen` (cloned to `~/bin/zgen` by bootstrap)
- `tree-sitter-cli` for full nvim treesitter functionality
- `tpm` (tmux plugin manager, cloned by bootstrap)
- The aliases assume `nvim` is installed (`alias vim='nvim'`).

Submodules (`.gitmodules`): `bin/z` (rupa/z) and `bin/zgen`.

## Neovim architecture

`dotfiles/nvim/init.vim` sources `~/.vimrc` first (shared Vim base), then — only under `if has('nvim')` — bootstraps plugins via `lua require('plugins')`. The Lua layer under `dotfiles/nvim/lua/`:

- `plugins.lua` — lazy.nvim setup (auto-installs lazy.nvim if absent). The `nvim-cmp` plugin's `config` calls `require('completion')` then `require('lsp')`, so completion is set up before LSP (LSP consumes cmp capabilities).
- `lsp.lua` — uses **native Neovim 0.11+ LSP** (`vim.lsp.config`/`vim.lsp.enable`), not lspconfig's old setup style. Mason auto-installs the servers listed in `mason_packages` (lua-language-server, pyright, gopls, jdtls, ruby-lsp). LSP keybindings (`gd`, `K`, `gr`, etc.) are bound in the `LspAttach` autocmd.
- `completion.lua`, `treesitter.lua` — nvim-cmp and treesitter config.
- `lazy-lock.json` — plugin lockfile; commit changes to it when adding/updating plugins.

When adding an LSP server: add the Mason package name to `mason_packages`, add a `vim.lsp.config(...)` block, and add it to the `vim.lsp.enable({...})` list in `lsp.lua`.

## Codex IDE integration

The Neovim-only Codex IDE provider is self-contained under
`dotfiles/nvim/codex_ide/`:

- `lua/codex_ide/` — IPC framing/server, editor-context snapshots, private
  Codex-home lifecycle, and the Codex-specific Sidekick adapter.
- `tests/codex_ide_spec.lua` — dependency-free headless Neovim coverage.
- `README.md` — protocol contract, supported Codex release, limitations, and
  the upgrade checklist. Read it before changing the provider or protocol.

`plugins.lua` prepends this directory to `runtimepath` and retains general
Sidekick preferences (`nes`, Copilot status, CLI window/mux/watch settings).
`codex_ide.sidekick` must stay limited to IDE integration: `<Leader>zc`, the
Visual-mode `<Leader>xx` focus override, `/ide on` lifecycle, and the Codex
tool's isolated `CODEX_HOME` / process matcher. Do not change the existing
`<Leader>xc`, normal `<Leader>xx`, or `<Leader>xs` mappings as part of Codex
IDE work.

Every Neovim process gets a temporary private `CODEX_HOME` for its Sidekick
Codex process, avoiding contention at `~/.codex/ipc/ipc.sock`. The private
home symlinks credentials, configuration, sessions, session index, and
history from the regular Codex home; preserve those links so `/resume` keeps
working. This is deliberately per-Neovim, not a shared-socket router.

The provider is Unix-only and implements a small, private Codex CLI IPC
protocol. Keep its public API (`require("codex_ide").open()`, `start()`,
`stop()`, `status()`) and commands (`:CodexIdeStart`, `:CodexIdeStop`,
`:CodexIdeStatus`) stable unless the README's pinned upstream protocol review
calls for a coordinated update. IDE-context requests arrive in a libuv fast
event; schedule any Neovim API work before taking a context snapshot.

Visual selection is retained proactively while it changes, because moving
focus to the Codex pane exits Visual mode. Do not regress this to capture only
when `<Leader>zc` is pressed or when Visual mode exits.

Run the focused tests from `dotfiles/nvim`:

```sh
env XDG_STATE_HOME=/private/tmp/codex-ide-state \
  nvim --headless -u NONE -i NONE '+set noswapfile' \
  -l codex_ide/tests/codex_ide_spec.lua
```

The optional real Unix-socket round-trip test needs
`CODEX_IDE_SOCKET_TEST=1`; sandboxed environments may deny Unix-domain socket
binding. Also verify a normal Neovim startup and, when protocol behavior
changes, manually test `/ide status`, a multiline selection, and `/resume` in
a Sidekick Codex terminal.
