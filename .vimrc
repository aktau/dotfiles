" some distros linux distros set filetype in /etc/vimrc
filetype off
filetype plugin indent off

" adjust runtime path (to test our new installation)
set rtp+=~/.vim/bundle/vundle/
" let &rtp = substitute(&rtp, $HOME."/\.vim", $HOME."/newvim/\.vim", "g")

set nocompatible               " be iMproved
set modelines=0

if has('mac')
    " fix clipboard on osx, do note that
    " when running from within tmux, you
    " might need something like
    " https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard
    set clipboard+=unnamed
endif

call vundle#rc()

" let vundle manage vundle
Bundle 'gmarik/vundle'

" original repos on github
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-eunuch'
Bundle 'tpope/vim-unimpaired'
Bundle 'kien/ctrlp.vim'
Bundle 'rking/ag.vim'
Bundle 'ervandew/supertab'
Bundle 'tomtom/tcomment_vim'
Bundle 'Lokaltog/vim-powerline'
Bundle 'airblade/vim-gitgutter'
Bundle 'vim-scripts/YankRing.vim'

" themes
Bundle 'altercation/vim-colors-solarized'
Bundle 'chriskempson/tomorrow-theme', {'rtp': 'vim/'}
Bundle 'tomasr/molokai'
Bundle 'zaiste/Atom'
Bundle 'jnurmine/Zenburn'
Bundle 'jpo/vim-railscasts-theme'

" language support
Bundle 'rodjek/vim-puppet'

" golang
set rtp+=$GOROOT/misc/vim
set rtp+=$GOPATH/src/github.com/nsf/gocode/vim
autocmd FileType go let g:SuperTabDefaultCompletionType = "context"
autocmd FileType go setlocal makeprg=go\ build
autocmd FileType go setlocal noexpandtab shiftwidth=4 tabstop=4 softtabstop=4 nolist
autocmd BufWritePre *.go Fmt

set encoding=utf-8
set termencoding=utf-8
scriptencoding utf-8

syntax enable
filetype plugin indent on         " load file type plugins + indentation

set showcmd                       " display incomplete commands.
set showmode                      " display the mode you're in.
set showmatch                     " show matching brackets/parenthesis
set mat=5                         " duration to show matching tabs
set autoread                      "

" text preferences
set nowrap                        " don't wrap lines
set tabstop=4 shiftwidth=4        " a tab is two spaces (or set this to 4)
set softtabstop=4
set expandtab                     " use spaces, not tabs (optional)
set nosmarttab                    " really get rid of tabs
set backspace=indent,eol,start    " backspace through everything in insert mode"
set autoindent                    " match indentation of previous line
set textwidth=76                  " in new gvim windows
set colorcolumn=85
set pastetoggle=<F2>

" show invisible characters
set list
" som alternatives: tab:▸\,eol:¬
set listchars=tab:\|\ ,trail:…

" searching
nnoremap / /\v
vnoremap / /\v
set incsearch                     " Find as you type search
set hlsearch                      " Highlight search terms
set ignorecase                    " Case-insensitive searching.
set smartcase                     " But case-sensitive if expression contains a capital letter.
set gdefault                      " Set the global flag on substitute commands by default
" set showmatch                     " When a bracket is inserted, briefly jump to the matching one

" undo
set undofile                      " Save undo's after file closes
set undodir=$HOME/.vim/undo       " where to save undo histories
set undolevels=1000               " How many undos
set undoreload=10000              " number of lines to save for undo

set hidden                        " Handle multiple buffers better.
set title                         " Set the terminal's title
set number                        " Show line numbers.
set ruler                         " Show cursor position.
set cursorline                    " Highlight current line
set wildmode=list:longest         " Complete files like a shell.
set wildmenu                      " Enhanced command line completion.
set wildignore=*.o,*.obj,*~       " Stuff to ignore when tab completing
set magic                         " magic matching

" small tweaks
set ttyfast                       " indicate a fast terminal connection
set tf                            " improve redrawing for newer computers
set nolazyredraw                  " turn off lazy redraw
set shell=/bin/zsh

set visualbell
set noerrorbells
set history=1000                  " Store lots of :cmdline history

set scrolloff=3
set sidescrolloff=7

set splitbelow
set splitright

set mouse-=a
set mousehide
set ttymouse=xterm2
set sidescroll=1

set nobackup                      " Don't make a backup before overwriting a file.
set nowritebackup                 " And again.
set directory=/tmp                " Keep swap files in one location
set noswapfile
set timeoutlen=500

set laststatus=2                  " Show the status line all the time
set statusline=[%n]\ %<%.99f\ %h%w%m%r%y\ %{exists('*CapsLockStatusline')?CapsLockStatusline():''}%=%-16(\ %l,%c-%v\ %)%P

set t_Co=256                      " Set terminal to 256 colors
colorscheme static_tomorrownight
set background=dark

autocmd FileType python setlocal tabstop=8 expandtab shiftwidth=4 softtabstop=4

" clear trailing spaces on save
autocmd BufWritePre * kz|:%s/\s\+$//e|'z

let mapleader = ","

" indent/unindent visual mode selection with tab/shift+tab
vmap <tab> >gv
vmap <s-tab> <gv

" F7 reformats the whole file and leaves you where you were (unlike gg)
map <silent> <F7> mzgg=G'z :delmarks z<CR>:echo "Reformatted."<CR>

" open the definition in a new split
nnoremap <c-\> <c-w>g<c-]>

" fix trailing spaces
nnoremap <leader>w :%s/\s\+$//<cr>:let @/=''<CR>

" search with ag
nnoremap <leader>a :Ag

" save on ctrl-s in every mode, does not work under tmux
noremap <C-S> :update<CR>
vnoremap <C-S> <C-C>:update<CR>
inoremap <C-S> <C-O>:update<CR>

" re-hardwrap paragraphs
nnoremap <leader>q gqip

" close the quickfix window
map <leader>qc :cclose<cr>

" switch split windows
nnoremap <leader>s <C-w>v<C-w>l
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" re-select text you just pasted
nnoremap <leader>v V`]

" open .vimrc in a split panel and edit it
nnoremap <leader>ev <C-w><C-v><C-l>:e $MYVIMRC<cr>

" clear search results
nnoremap <leader><space> :noh<cr>

" make and open quickfix window
map <silent> <F7> :make %<CR>:copen<CR>

" % is hard to type
" nnoremap <tab> %
" vnoremap <tab> %

" quit insert-mode by pressing jj, most people don't type jj's very often
" inoremap jj <ESC>
inoremap ;; <Esc>

" sane movement with wrap turned on

""""""""""""""""""""""
" plugin customization
""""""""""""""""""""""

" ctrlp.vim
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*   " for Linux/MacOSX
set wildignore+=*/tmp/*,*.so,*.swp,*.zip

" vim-gitguttter
highlight clear SignColumn
"let g:gitgutter_sign_column_always = 1

" yankring.vim
nnoremap <silent> <F3> :YRShow<cr>
inoremap <silent> <F3> <ESC>:YRShow<cr>

""""""""""""""""""""
" filetype detection
""""""""""""""""""""

if has('autocmd')
    au WinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
    hi ExtraWhitespace ctermbg=red guibg=red
    au ColorScheme * hi ExtraWhitespace ctermbg=red guibg=red
    match ExtraWhitespace /\s\+$\| \+\ze\t/

    " Fix filetype detection
    au BufNewFile,BufRead *.inc set filetype=php
    au BufNewFile,BufRead *.sys set filetype=php
    au BufNewFile,BufRead grub.conf set filetype=grub
    au BufNewFile,BufRead *.blog set filetype=blog

    " C file specific options
    au FileType c,cpp set cindent
    au FileType c,cpp set formatoptions+=ro

    " Ruby file specific options
    au Filetype ruby set textwidth=80 ts=2
    au Filetype haml set ts=2 sw=2 sts=0 expandtab tw=120

    au FileType javascript setlocal nocindent

    au BufRead,BufNewFile *.rpdf set ft=ruby
    au BufRead,BufNewFile *.rxls set ft=ruby
    au BufRead,BufNewFile *.ru set ft=ruby
    au BufRead,BufNewFile *.god set ft=ruby
    au BufRead,BufNewFile *.rtxt set ft=html spell
    au BufRead,BufNewFile *.rl set ft=ragel
    au BufRead,BufNewFile *.haml set ft=haml
    au BufRead,BufNewFile *.mustache set ft=mustache
    au BufRead,BufNewFile *.ron set ft=mkd tw=65 ts=2 sw=2 expandtab

    " Others..
    au BufRead,BufNewFile *.sql set ft=pgsql
    au BufRead,BufNewFile *.svg set ft=svg

    au BufRead,BufNewFile *.vimp set ft=vimperator

    au BufRead,BufNewFile *.md set ft=mkd tw=72 ts=2 sw=2 expandtab
    au BufRead,BufNewFile *.markdown set ft=mkd tw=72 ts=2 sw=2 expandtab

    au BufRead,BufNewFile *.coffee set ft=coffee

    au BufRead,BufNewFile mutt{ng,}-*-\w\+ set ft=mail

    " Python file specific options
    au FileType python set omnifunc=pythoncomplete#Complete

    " Compile and run keymappings
    au FileType php map <leader>r :!php -f %<CR>
    au FileType python map <leader>r :!python %<CR>
    au FileType perl map <leader>r :!perl %<CR>
    au FileType ruby map <leader>r :!ruby %<CR>
    au FileType lua map <leader>r :!lua %<CR>
    au FileType html,xhtml map <leader>r :!firefox %<CR>
    au FileType go map <leader>r :!go run %<CR>

    " MS Word document reading
    au BufReadPre *.doc set ro
    au BufReadPre *.doc set hlsearch!
    au BufReadPost *.doc %!antiword "%"

    " Git
    au BufRead,BufNewFile COMMIT_EDITMSG set ft=git

    " Reload vimrc when we edit it
    au! BufWritePost .vimrc source %
endif
