" ~/.vimrc
" Heavily borrowed from https://raw.githubusercontent.com/tpope/dotfiles/master/.vimrc
set nocompatible                  " be iMproved, required

" Section: vim-plug

call plug#begin()

Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-dispatch'

Plug 'tpope/vim-fugitive'
Plug 'notriddle/vim-gitcommit-markdown'

Plug 'NLKNguyen/papercolor-theme'

Plug 'ntpeters/vim-better-whitespace'

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }    " maps C-t to NERDTreeToggle

Plug 'vim-airline/vim-airline'

Plug 'frazrepo/vim-rainbow' " Colorful brackets

Plug 'fatih/vim-go', { 'tag': '*' }

Plug 'pearofducks/ansible-vim'

Plug 'liuchengxu/graphviz.vim'
Plug 'aklt/plantuml-syntax'

Plug 'jmcantrell/vim-virtualenv'
Plug 'nvie/vim-flake8'
" Plugin 'psf/black'

Plug 'junegunn/vim-easy-align'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

Plug 'honza/vim-snippets' " Snippets

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc-json', {'do': 'yarn install --frozen-lockfile'}
call plug#end()

" Enable file type detection, if plugin manager does not.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on
syntax enable

" Section: Editing text and indent

setglobal backspace=indent,eol,start " allow backspacing over everything in insert mode
setglobal tabstop=4 softtabstop=4 expandtab shiftwidth=4
silent! setglobal dictionary+=/usr/share/dict/words

" Section: Command line editing

setglobal history=1000    " keep 1000 lines of command line history

setglobal wildmenu
setglobal wildmode=full
setglobal wildignore+=tags,.*.un~,*.pyc


" Section: Messages and info

setglobal showcmd   " display incomplete commands
setglobal ruler     " show the cursor position all the time

" Section: Moving around, searching, patterns, and tags

set incsearch           " do incremental searching
set maxmempattern=5000

" Section: Maps

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Section: Windows

nnoremap <C-J> <C-w>w
nnoremap <C-K> <C-w>W

setglobal hidden    " Suppress unsaved dialog while switching buffers

" Section: GUI

" In many terminal emulators the mouse works just fine, thus enable it.
" if has('mouse')
"     set mouse=
" endif

" Section: Highlighting and Colors

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
    if !exists('syntax_on') && !exists('syntax_manual')
        syntax on
    endif

    set hlsearch

    if has('vim_starting')
        " add theme."default.dark".allow_italic: 1
        if !exists('g:colors_name')
            let g:PaperColor_Theme_Options = {
                \   'theme': {
                \     'default.dark': {
                \       'transparent_background': 1,
                \       'allow_italic': 0
                \     }
                \   }
                \ }
            colorscheme PaperColor
        endif
    endif

    if !has('gui_running') | set noicon background=dark | endif

endif

" Section: Folding

if has('folding')
    set foldmethod=marker
    set foldlevel=99
    set foldnestmax=1
endif

" Section: Custom commands

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
                    \ | wincmd p | diffthis
endif


" Section: Reading and writing files

setglobal autoread
setglobal autowrite

if has('vim_starting') && exists('+undofile')
    set undofile
endif

setglobal viminfo=!,'20,<50,s10,h

if !empty($SUDO_USER) && $USER !=# $SUDO_USER
    " When editing as root, don't write backup and swap files in /tmp
    setglobal viminfo=
    setglobal directory-=~/tmp
    setglobal backupdir-=~/tmp
elseif exists('+undodir')
    if !empty($XDG_DATA_HOME)
        let s:data_home = substitute($XDG_DATA_HOME, '/$', '', '') . '/vim/'
    elseif has('win32')
        let s:data_home = expand('~/AppData/Local/vim/')
    else
        let s:data_home = expand('~/.local/share/vim/')
    endif
    let &undodir = s:data_home . 'undo//'
    let &directory = s:data_home . 'swap//'
    let &backupdir = s:data_home . 'backup//'
    if !isdirectory(&undodir) | call mkdir(&undodir, 'p') | endif
    if !isdirectory(&directory) | call mkdir(&directory, 'p') | endif
    if !isdirectory(&backupdir) | call mkdir(&backupdir, 'p') | endif
endif

if has("autocmd")
    " https://gist.github.com/nepsilon/003dd7cfefc20ce1e894db9c94749755
    " Meaningful backup name, ex: filename@2015-04-05.14:59
    autocmd BufWritePre * let &bex = '@' . strftime("%F.%H:%M")

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    " (happens when dropping a file on gvim).
    " Also don't do it when the mark is in the first line, that is the default
    " position when opening a file.
    autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif
endif

" Section: FileType settings

if has("autocmd")

    " Enable file type detection
    filetype on

    autocmd FileType python setlocal autoindent tabstop=4 softtabstop=4
                                \ expandtab smarttab shiftwidth=4 textwidth=78
                                \ formatoptions=2ntcroqlv

    autocmd FileType go setlocal autoindent tabstop=4 softtabstop=4
                                \ shiftwidth=4 expandtab smarttab

    autocmd FileType json setlocal autoindent tabstop=4 softtabstop=4
                                \ shiftwidth=4 expandtab smarttab textwidth=78
                                \ formatoptions=tcq2l

    autocmd FileType vim,dot,plantuml setlocal autoindent tabstop=4 softtabstop=4
                                \ shiftwidth=4 expandtab smarttab

    autocmd FileType yaml,yaml.ansible setlocal autoindent tabstop=2
                                \ softtabstop=2 shiftwidth=2 expandtab smarttab

endif

" Section: vim-airline

" Automatically display all buffers when there's only one tab open
let g:airline#extensions#tabline#enabled=1
let g:airline_powerline_fonts=1
let g:airline#extensions#virtualenv#enabled=1

" Section: ansible-vim

" In yaml.ansible filetype, unindent to column 0 after two new lines
let g:ansible_unindent_after_newline = 1

let g:ansible_extra_keywords_highlight = 1  " highlight extra ansible keywords

" Section: vim-easy-align

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Section: fzf

" Mapping selecting mappings
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-l> <plug>(fzf-complete-line)

" No modeline when fzf window is displayed
autocmd! FileType fzf set laststatus=0 noshowmode noruler
    \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

" Section: vim-rainbow

let g:rainbow_active = 1    " Enable rainbow parentheses everywhere

" Section: vim-python

let g:python_highlight_all = 1

" Section: vim-dispatch

autocmd FileType plantuml let b:dispatch = 'plantuml %'

" Section: Sessions

" setglobal sessionoptions-=buffers sessionoptions-=curdir sessionoptions+=sesdir,globals
autocmd VimEnter * nested
      \ if !argc() && empty(v:this_session) && filereadable('Session.vim') && !&modified |
      \   source Session.vim |
      \ endif

" Section: Fin

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif

"set t_ZH=[3m
"set t_ZR=[23m
