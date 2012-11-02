set nocompatible

"""" Vundle setup """"
filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'

" Own bundles
Bundle 'altercation/vim-colors-solarized'
Bundle 'kchmck/vim-coffee-script'
Bundle 'digitaltoad/vim-jade'
Bundle 'mattn/zencoding-vim'
Bundle 'pangloss/vim-javascript'
Bundle 'scrooloose/syntastic'
"Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-rails'
"Bundle 'tpope/vim-endwise'
"Bundle 'tpope/vim-repeat'
"Bundle 'tpope/vim-speeddating'
Bundle 'tpope/vim-markdown'
"Bundle 'tpope/vim-commentary'
Bundle 'tpope/vim-haml'
" Bundle 'wincent/Command-T'
Bundle 'sjl/gundo.vim'
Bundle 'sjbach/lusty'

"""" End Vundle setup """"

" Place backup/swp files somewhere else
set backupdir=~/.vimtmp/backup
set dir=~/.vimtmp/swp

" Ignore these files when tabbing
set wildignore=*.o,*.pyc,*.hi,*.swp,*.class

" Default settings for tabbing
set smartindent
set expandtab ts=4 sw=4 sts=4 ai

set tw=80

"""" More specific settings for tabbing
autocmd Filetype html setlocal ts=2 sts=2 sw=2
autocmd Filetype css setlocal ts=2 sts=2 sw=2
autocmd Filetype python setlocal nosmartindent textwidth=80 smarttab
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2 nosmartindent smarttab bs=2
autocmd Filetype jade setlocal ts=2 sts=2 sw=2
autocmd Filetype javascript setlocal ts=2 sts=2 sw=2
autocmd Filetype tex setlocal ts=4 sts=4 sw=4
autocmd Filetype haskell setlocal ts=2 sts=2 sw=2
autocmd Filetype gitcommit setlocal tw=72
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
set showmatch

" Auto-completions
set ofu=syntaxcomplete#Complete
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS


"""" Miscellaneous

set hidden

" Get rid of trailing whitespace in certain files
autocmd FileType c,cpp,cc,html,css,py,hs,js,clj autocmd BufWritePre <buffer> :%s/\s\+$//e

" Haskell settings
au BufEnter *.hs compiler ghc
" Configure browser for haskell_doc.vim
let g:haddock_browser = "open"
let g:haddock_browser_callformat = "%s %s"

" Zen settings (for HTML+XML)
let g:user_zen_settings = {
\  'indentation': '  '
\}

" HTML/XML settings
let g:closetag_html_style=1
au Filetype html,xml,xsl source ~/.vim/scripts/closetag.vim 

" Map NERDTree to \t
nmap <silent> <Leader>t :NERDTreeToggle<CR>

" LaTeX settings
let g:tex_flavor='latex'

" Ctag (doesn't ever seem to make a difference...)
let Tlist_Ctags_Cmd="/usr/bin/ctags"

" Automatically change current directory to current file
" autocmd BufEnter * silent! lcd %:p:h

" gundo
nnoremap <F5> :GundoToggle<CR>

" Solarized
set background=light
let g:solarized_contrast="high"
colorscheme solarized
