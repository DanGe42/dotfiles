set nocompatible

" Default settings for tabbing
set smartindent
set expandtab ts=4 sw=4 sts=4 ai

"""" More specific settings for tabbing
autocmd Filetype html setlocal ts=2 sts=2 sw=2
autocmd Filetype css setlocal ts=2 sts=2 sw=2
autocmd Filetype python setlocal nosmartindent textwidth=80 smarttab
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2 nosmartindent smarttab
""""

" Everything related to syntax highlighting
syntax on
filetype plugin indent on

" View settings
" colorscheme koehler
set cursorline
highlight CursorLine ctermbg=8 cterm=NONE
set number      " Line numbers
set showcmd     " Show current command on status bar
set ruler

" Searching
set incsearch
set ignorecase
set smartcase
set hlsearch

" Auto-completions
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS


"""" Miscellaneous
" Get rid of trailing whitespace in certain files
autocmd FileType c,cpp,cc,html,css,py,hs,js,clj autocmd BufWritePre <buffer> :%s/\s\+$//e

" Haskell settings
au BufEnter *.hs compiler ghc
let g:haddock_browser="/usr/bin/firefox"

" Zen settings (for HTML+XML)
let g:user_zen_settings = {
\  'indentation': '  '
\}

" HTML/XML settings
let g:closetag_html_style=1
au Filetype html,xml,xsl source ~/.vim/scripts/closetag.vim 

" Map NERDTree to \t
nmap <silent> <Leader>t :NERDTreeToggle<CR>

" Ctag (doesn't ever seem to make a difference...)
let Tlist_Ctags_Cmd="/usr/bin/ctags"

" Automatically change current directory to current file
" autocmd BufEnter * silent! lcd %:p:h

" Pathogen
call pathogen#infect()

" Solarized
set background=dark
let g:solarized_contrast="high"
colorscheme solarized
