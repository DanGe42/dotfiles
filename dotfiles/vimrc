set nocompatible

"""" NeoBundle setup """"
if has('vim_starting')
    set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

" Solarized
NeoBundle 'altercation/vim-colors-solarized'

" Language-specific
NeoBundleLazy 'jrk/vim-ocaml'
NeoBundleLazy 'kchmck/vim-coffee-script'
NeoBundleLazy 'pangloss/vim-javascript'
NeoBundleLazy 'digitaltoad/vim-jade'
NeoBundle 'tpope/vim-rails'
NeoBundleLazy 'tpope/vim-haml'
NeoBundleLazy 'tpope/vim-markdown'
NeoBundle 'gregsexton/MatchTag'
NeoBundleLazy 'pbrisbin/html-template-syntax'
NeoBundleLazy 'rkulla/pydiction'
NeoBundleLazy 'klen/python-mode'
NeoBundleLazy 'fatih/vim-go'
NeoBundleLazy 'git://git.code.sf.net/p/vim-latex/vim-latex'
NeoBundle 'the-lambda-church/coquille'
NeoBundleLazy 'wting/rust.vim'
NeoBundle 'vim-pandoc/vim-pandoc'
NeoBundle 'vim-pandoc/vim-pandoc-syntax'

" Other tpope shenanigans
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-endwise'
"NeoBundle 'tpope/vim-repeat'
"NeoBundle 'tpope/vim-speeddating'
"NeoBundle 'tpope/vim-commentary'

" Misc
NeoBundle 'scrooloose/syntastic'
NeoBundle 'Valloric/YouCompleteMe'
NeoBundle 'sjl/gundo.vim'
NeoBundle 'benmills/vimux'
NeoBundle 'sjbach/lusty'
" NeoBundle 'vim-scripts/Align'
NeoBundle 'junegunn/vim-easy-align'
NeoBundle 'bling/vim-airline'
NeoBundle 'bronson/vim-trailing-whitespace'

call neobundle#end()

filetype plugin indent on
"""" End NeoBundle setup """"

" Place backup/swp files somewhere else
set backupdir=~/.vimtmp/backup
set dir=~/.vimtmp/swp

" Ignore these files when tabbing
set wildignore=*.o,*.pyc,*.hi,*.swp,*.class

" Enable backspace to delete from insertion point
set backspace=2

" Sane splitting behavior
set splitbelow
set splitright

let g:pymode_rope_complete_on_dot=0
let g:pydiction_location='~/.vim/bundle/pydiction/complete-dict'

" Everything related to syntax highlighting
syntax on

" Default settings for tabbing
set nosmartindent
set expandtab tabstop=4 shiftwidth=4 softtabstop=4 autoindent

set textwidth=80

" Auto-completions
set omnifunc=syntaxcomplete#Complete

"""" Language specific settings
function DGSetIndent(spaces)
    """ Sets indentation. """
    let &tabstop=a:spaces
    let &softtabstop=a:spaces
    let &shiftwidth=a:spaces
endfunction

augroup lang_setup
    autocmd!

    " NeoBundle
    autocmd FileType coffee     NeoBundleSource "vim-coffee-script"
    autocmd FileType go         NeoBundleSource "vim-go"
    autocmd FileType haml       NeoBundleSource "vim-haml"
    autocmd FileType jade       NeoBundleSource "vim-jade"
    autocmd FileType javascript NeoBundleSource "vim-javascript"
    autocmd FileType markdown   NeoBundleSource "vim-markdown"
    autocmd FileType ocaml      NeoBundleSource "vim-ocaml"
    autocmd FileType python     NeoBundleSource "pydiction"
    autocmd FileType python     NeoBundleSource "python-mode"
    autocmd FileType tex        NeoBundleSource "vim-latex"
    autocmd FileType rust       NeoBundleSource "rust.vim"

    " Auto-complete via omnifunc
    autocmd Filetype css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd Filetype html setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd Filetype javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd Filetype python setlocal omnifunc=pythoncomplete#Complete

    " Indentation
    autocmd Filetype c          call DGSetIndent(4)
    autocmd Filetype css        call DGSetIndent(2)
    autocmd Filetype haskell    call DGSetIndent(2)
    autocmd Filetype html       call DGSetIndent(2)
    autocmd Filetype jade       call DGSetIndent(2)
    autocmd Filetype javascript call DGSetIndent(2)
    autocmd Filetype ocaml      call DGSetIndent(2)
    autocmd Filetype php        call DGSetIndent(2)
    autocmd Filetype ruby       call DGSetIndent(2)
    autocmd Filetype tex        call DGSetIndent(4)
    autocmd Filetype verilog    call DGSetIndent(3)

    autocmd Filetype c setlocal cindent

    " Misc
    autocmd Filetype gitcommit setlocal tw=72
    autocmd Filetype c setlocal smarttab
    autocmd Filetype ruby setlocal nosmartindent
    autocmd Filetype python setlocal nosmartindent
    autocmd BufRead *.py setlocal nosmartindent
    autocmd Filetype html setlocal indentkeys-=*<Return>
    autocmd Filetype php setlocal indentkeys-=*<Return>
    autocmd Filetype markdown setlocal tw=80

augroup END

""""

" View settings
" colorscheme koehler
set cursorline
highlight CursorLine ctermbg=8 cterm=NONE
set number      " Line numbers
"set relativenumber
set showcmd     " Show current command on status bar
set ruler

" Searching
set incsearch
set ignorecase
set smartcase
set hlsearch
set showmatch


"""" Miscellaneous

set hidden

" Show 80-character column
set colorcolumn=80

" Powerline settings
" let g:Powerline_symbols = 'fancy'

" vim-airline settings
set ttimeoutlen=50
set laststatus=2
set encoding=utf-8
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" Get rid of trailing whitespace in certain files
autocmd FileType c,cpp,cc,html,css,py,hs,js,clj autocmd BufWritePre <buffer> :%s/\s\+$//e

" Haskell settings
au BufEnter *.hs compiler ghc
" Configure browser for haskell_doc.vim
let g:haddock_browser = "open"
let g:haddock_browser_callformat = "%s %s"

" OCaml settings
let g:syntastic_ocaml_use_ocamlc = 1

" Python settings
let g:pymode_lint_checker = 'pyflakes,mccabe'
let g:pymode_lint_ignore = 'E501,C0110'

" Zen settings (for HTML+XML)
let g:user_zen_settings = {
\  'indentation': '  '
\}

" Map NERDTree to \t
nmap <silent> <Leader>t :NERDTreeToggle<CR>

" LaTeX settings
let g:tex_flavor='latex'

" Ctag (doesn't ever seem to make a difference...)
let Tlist_Ctags_Cmd="/usr/bin/ctags"

" Automatically change current directory to current file
" autocmd BufEnter * silent! lcd %:p:h

" Keyboard remappings
" gundo
nnoremap <F5> :GundoToggle<CR>
" :noh
nnoremap <F9> :nohlsearch<CR>
" :YcmForceCompileAndDiagnostics
nnoremap <S-F5> :YcmForceCompileAndDiagnostics<CR>

" Solarized
set background=light
let g:solarized_contrast="high"
colorscheme solarized
