" ~/.vimrc
" Heavily borrowed from https://raw.githubusercontent.com/tpope/dotfiles/master/.vimrc
set nocompatible                  " be iMproved, required

" Section: vim-plug

call plug#begin()

Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'

Plug 'notriddle/vim-gitcommit-markdown'

Plug 'jpalardy/vim-slime'

Plug 'ntpeters/vim-better-whitespace'

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }    " maps C-t to NERDTreeToggle

Plug 'vim-airline/vim-airline'

Plug 'frazrepo/vim-rainbow' " Colorful brackets

Plug 'fatih/vim-go', { 'tag': '*' }

Plug 'rust-lang/rust.vim'

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

    " de-emphasize comments
    highlight Comment ctermfg=Gray

    "if !has('gui_running') | set noicon background=dark | endif

endif

" 24-bit color
if has("termguicolors")
    set termguicolors
endif

set listchars=tab:▸\ ,eol:¬,space:.

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

    autocmd BufRead,BufNewFile *.gohtml set filetype=gohtmltmpl

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
nnoremap <silent> <c-p> :Files<CR>
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-l> <plug>(fzf-complete-line)

" Do not show mode when fzf window is displayed
autocmd! FileType fzf set laststatus=0 noshowmode noruler
    \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

" Section: vim-rainbow

let g:rainbow_active = 1    " Enable rainbow parentheses everywhere

" Section: vim-python

let g:python_highlight_all = 1

" Section: rust

let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0

" Section: vim-dispatch

autocmd FileType plantuml let b:dispatch = 'plantuml %'

" Section: coc-vim

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set invnumber signcolumn=number

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <c-@> coc#refresh()

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>


function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)


" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)


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
