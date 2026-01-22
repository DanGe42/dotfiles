" Neovim configuration
" Sources ~/.vimrc for core Vim settings, then adds Neovim-specific features

" ============================================================================
" Source base Vim configuration
" ============================================================================
source ~/.vimrc

" ============================================================================
" Neovim-specific: Modern features via Lua
" ============================================================================

" Only run if Neovim
if has('nvim')
  " Plugin management (lazy.nvim) - this will also configure LSP and completion
  lua require('plugins')

  " Optional: Treesitter (uncomment when ready)
  " lua require('treesitter')

  " ========================================================================
  " Plugin-specific settings (VimScript)
  " ========================================================================

  " vim-airline
  set ttimeoutlen=50
  set laststatus=2
  set encoding=utf-8
  let g:airline_powerline_fonts = 1
  let g:airline#extensions#tabline#enabled = 1

  " LaTeX
  let g:tex_flavor='latex'

  " undotree
  nnoremap <F5> :UndotreeToggle<CR>
  nnoremap <leader>u :UndotreeToggle<CR>

  " fzf.vim
  nnoremap <C-p> :Files<CR>
  nnoremap <leader>f :Files<CR>
  nnoremap <leader>b :Buffers<CR>
  nnoremap <leader>r :Rg<CR>
  nnoremap <leader>l :Lines<CR>
endif
