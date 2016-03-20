" some distros linux distros set filetype in /etc/vimrc
filetype off
filetype plugin indent off

set nocompatible               " be iMproved
set modelines=0

if has('mac')
    " fix clipboard on osx, do note that when running from within tmux, you
    " might need something like
    " https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard
    set clipboard+=unnamed
else
    set clipboard=unnamedplus
endif

if executable('fzf')
  if isdirectory($GOPATH . '/src/github.com/junegunn/fzf')
    exe 'set rtp+=' . $GOPATH . '/src/github.com/junegunn/fzf'
  else
    exe 'set rtp+=' . fnamemodify(resolve(systemlist('which fzf')[0]), ':h:h')
  endif
endif

" Install vim-plug if it's missing. Need curl(1) though.
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.vim/bundle')

" original repos on github
Plug 'airblade/vim-gitgutter'
Plug 'ajh17/VimCompletesMe'
Plug 'aktau/vim-easytags'
Plug 'b4winckler/vim-angry'
Plug 'chrisbra/vim-diff-enhanced'
Plug 'danro/rename.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'godlygeek/tabular'
Plug 'itchyny/lightline.vim'
Plug 'ivalkeen/vim-ctrlp-tjump'
Plug 'ivalkeen/vim-simpledb'
Plug 'kien/ctrlp.vim'
Plug 'nhooyr/neoman.vim'
Plug 'rhysd/clever-f.vim'
Plug 'rking/ag.vim'
Plug 'scrooloose/syntastic'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'xolox/vim-misc'
Plug 'xuhdev/SingleCompile'

" themes
Plug 'jnurmine/Zenburn'
Plug 'https://bitbucket.org/kisom/eink.vim.git'
Plug 'robertmeta/nofrils'

" language support
Plug 'exu/pgsql.vim'
Plug 'fatih/vim-go'
Plug 'nfnty/vim-nftables'
Plug 'rodjek/vim-puppet'

let mapleader = ","
" Enable any local modifications
if filereadable($HOME . '/.local_config/local.vim')
  source ~/.local_config/local.vim
endif

call plug#end()

filetype plugin indent on         " load file type plugins + indentation
syntax enable

set encoding=utf-8
set termencoding=utf-8
scriptencoding utf-8

set showcmd                       " display incomplete commands.
set showmode                      " display the mode you're in.
set showmatch                     " show matching brackets/parenthesis
set mat=5                         " duration to show matching tabs
set autoread                      " reload files automagically

" text preferences
set nowrap                        " don't wrap lines
set tabstop=4 shiftwidth=4        " a tab is two spaces (or set this to 4)
set softtabstop=4
set expandtab                     " use spaces, not tabs (optional)
set nosmarttab                    " really get rid of tabs
set backspace=indent,eol,start    " backspace through everything in insert mode"
set autoindent                    " match indentation of previous line
set textwidth=76                  " in new gvim windows
set colorcolumn=80
set pastetoggle=<F2>
set formatoptions+=n              " format numbered lists properly
set nojoinspaces                  " Don't add extra spaces after join/fmt.

" show invisible characters
set list
" som alternatives: tab:▸\,eol:¬
set listchars=tab:\|\ ,trail:…

" searching
nnoremap <CR> :noh<CR><CR>
nnoremap / /\v
vnoremap / /\v
set incsearch                     " Find as you type search
set hlsearch                      " Highlight search terms
set ignorecase                    " Case-insensitive searching.
set smartcase                     " But case-sensitive if expression contains a capital letter.
set gdefault                      " Set the global flag on substitute commands by default
set matchpairs+=<:>               " Match < and > as well.
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

set sidescroll=1
set mouse-=a
set mousehide
if !has("nvim")
  set ttymouse=xterm2
endif

set nobackup                      " Don't make a backup before overwriting a file.
set nowritebackup                 " And again.
set directory=/tmp                " Keep swap files in one location
set noswapfile
set timeoutlen=500

set laststatus=2                  " Show the status line all the time

set t_Co=256                      " Set terminal to 256 colors
colorscheme static_tomorrownight
set background=dark

autocmd FileType python setlocal tabstop=8 expandtab shiftwidth=4 softtabstop=4

" clear trailing spaces on save
autocmd BufWritePre * kz|:%s/\s\+$//e|'z

" indent/unindent visual mode selection with tab/shift+tab
vmap <tab> >gv
vmap <s-tab> <gv

" F7 reformats the whole file and leaves you where you were (unlike gg)
map <silent> <F7> mzgg=G'z :delmarks z<CR>:echo "Reformatted."<CR>

" open the definition in a new split
nnoremap <c-\> <c-w>g<c-]>

" fix trailing spaces
nnoremap <leader>w :%s/\s\+$//<cr>:let @/=''<CR>

" map sort function to a key
vnoremap <leader>s :sort<CR>

" save on ctrl-s in every mode, does not work under tmux
noremap <C-S> :update<CR>
vnoremap <C-S> <C-C>:update<CR>
inoremap <C-S> <C-O>:update<CR>

" re-hardwrap paragraphs
nnoremap <leader>q gqip
vmap Q gq
nmap Q gqap

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

" select last matched item
nnoremap <leader>/ //e<Enter>v??<Enter>

" make and open quickfix window
map <silent> <F7> :make %<CR>:copen<CR>

" see what unsaved changes you have
nnoremap <leader>u :w !diff - %<CR>

" % is hard to type
" nnoremap <tab> %
" vnoremap <tab> %

" go to the end of the copied/yank text
vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

" enable the dot command in visual mode
vnoremap . :norm.<CR>

" oh dear... disable the arrow keys
map <Left> :echo "no!"<cr>
map <Right> :echo "no!"<cr>
map <Up> :echo "no!"<cr>
map <Down> :echo "no!"<cr>

" visual-at. Allow running macro's over a visual selection, just type @<reg>
" while in visual mode.
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

function! ExecuteMacroOverVisualRange()
  echo "@".getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
endfunction

""""""""""""""""""""""
" plugin customization
""""""""""""""""""""""

" ctrlp.vim
set wildignore+=*/.git/objects/*,*/.git/refs/*,*/.hg/*,*/.svn/*   " for Linux/MacOSX
set wildignore+=*/tmp/*,*.so,*.swp,*.zip

" vim-ctrlp-tjump
let g:ctrlp_tjump_only_silent = 1
nnoremap <c-]> :CtrlPtjump<cr>
vnoremap <c-]> :CtrlPtjumpVisual<cr>

" vim-gitgutter
highlight clear SignColumn
"let g:gitgutter_sign_column_always = 1

" vim-diff-enhanced
let &diffexpr='EnhancedDiff#Diff("git diff", "--diff-algorithm=patience")'

" gist-vim
let g:gist_detect_filetype = 1

" vim-sneak
let g:sneak#streak = 1

" syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
" let g:syntastic_auto_loc_list=1
" let g:syntastic_loc_list_height=5
let g:syntastic_c_include_dirs = [
            \ '../build/include',
            \ 'build/include',
            \ '../build/src/nvim/auto',
            \ 'build/src/nvim/auto',
            \ ]
let g:syntastic_c_compiler_options = '-std=gnu99 -DINCLUDE_GENERATED_DECLARATIONS'

let g:syntastic_go_checkers=['go', 'govet']

" vim-easytags
" don't enable this for now... editing a file in $HOME wrecks the HDD
" let g:easytags_autorecurse = 1
" set tags=./tags;/,tags;/
let g:easytags_dynamic_files = 2
let g:easytags_file = "~/.easytags"

" SingleCompile
nnoremap <leader>r :SCCompileRun<cr>

" vim-go
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_fmt_command = "goimports"

" tabularize
" some keybinds taken from the excellent vimcasts episode on Tabularize
nmap <Leader>a= :Tabularize /=<CR>
vmap <Leader>a= :Tabularize /=<CR>
nmap <Leader>a, :Tabularize /,<CR>
vmap <Leader>a, :Tabularize /,<CR>
nmap <Leader>a: :Tabularize /:\zs<CR>
vmap <Leader>a: :Tabularize /:\zs<CR>
nmap <Leader>a# :Tabularize /#<CR>
vmap <Leader>a# :Tabularize /#<CR>
nmap <Leader>a<bar> :Tabularize /\|<CR>
vmap <Leader>a<bar> :Tabularize /\|<CR>
nmap <Leader>a<tab> :Tabularize /\<tab><CR>
vmap <Leader>a<tab> :Tabularize /\<tab><CR>

" vim-unimpaired (not actually part of the plugin, but similar in spirit)
nmap <silent> [g :tabprevious<CR>
nmap <silent> ]g :tabnext<CR>
nmap <silent> [G :tabrewind<CR>
nmap <silent> ]G :tablast<CR>

" fzf
nmap <silent> <c-p> :FZF<CR>

" neoman.vim
" Vanilla vim doesn't support keywordprg being an Ex command.
if has('nvim')
  set keywordprg=:Nman
endif

" lightline
if !exists('g:lightline')
  " A sane default config for lightline. This ugliness (with the later
  " extending) is necessary because I conditionally include local configs that
  " may override g:lightline.
  let g:lightline = {
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'readonly', 'filename', 'modified' ] ]
    \ },
    \ }
endif

" Change filename component -> relativepath component if filename is present,
" which is nicer for my use-case. I should loop over all components, but meh.
let s:llIdx = index(g:lightline.active.left[1], 'filename')
if s:llIdx != -1
  let g:lightline.active.left[1][s:llIdx] = 'relativepath'
endif

" Add fugitive if it wasn't set yet.
let s:llIdx = index(g:lightline.active.left[1], 'fugitive')
if s:llIdx == -1
  if !has_key(g:lightline, 'component_function')
    let g:lightline['component_function'] = {}
  endif
  let g:lightline.component_function.fugitive = 'fugitive#statusline'
  call extend(g:lightline.active.left[1], ['fugitive'], 0)
endif

""""""""""""""""""""
" filetype detection
""""""""""""""""""""

if has('autocmd')
    au WinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
    au VimResized * wincmd = " Resize splits on window resize.
    hi ExtraWhitespace ctermbg=red guibg=red
    au ColorScheme * hi ExtraWhitespace ctermbg=red guibg=red
    match ExtraWhitespace /\s\+$\| \+\ze\t/

    " C file specific options
    au FileType c,cpp set cindent
    au FileType c,cpp set formatoptions+=roj
    au FileType c,cpp setlocal comments^=:///

    au FileType javascript setlocal nocindent

    au BufRead,BufNewFile *.rpdf set ft=ruby
    au BufRead,BufNewFile *.rxls set ft=ruby
    au BufRead,BufNewFile *.ru set ft=ruby
    au BufRead,BufNewFile *.god set ft=ruby
    au BufRead,BufNewFile *.sql set ft=pgsql
    au BufRead,BufNewFile *.svg set ft=svg
    au BufRead,BufNewFile *.dasc set ft=c
    au BufRead,BufNewFile *.coffee set ft=coffee
    au BufRead,BufNewFile mutt{ng,}-*-\w\+ set ft=mail

    " Go file specific options
    au FileType go setlocal formatoptions+=j

    au FileType go setlocal makeprg=go\ build
    au FileType go setlocal shiftwidth=4 tabstop=4 softtabstop=4 nolist
    au FileType go let g:SuperTabDefaultCompletionType = "context"

    au FileType go unmap <leader>r
    au FileType go nmap <leader>r <Plug>(go-run)
    au FileType go nmap <leader>b <Plug>(go-build)
    au FileType go nmap <leader>t <Plug>(go-test)
    au FileType go nmap <leader>c <Plug>(go-coverage)
    au FileType go nmap <leader>i <Plug>(go-info)
    au FileType go nmap <leader>d <Plug>(go-doc)
    au FileType go nmap <leader>n <Plug>(go-rename)
endif

""""""""""""""""""""""""
" hacks
""""""""""""""""""""""""

" tries to get buffer reloading to work correctly in terminals
augroup checktime
    au!
    if !has("gui_running")
        " silent! necessary otherwise throws errors when using command
        " line window.
        autocmd BufEnter        * silent! checktime
        autocmd CursorHold      * silent! checktime
        autocmd CursorHoldI     * silent! checktime
        " these two _may_ slow things down. Remove if they do.
        " autocmd CursorMoved     * silent! checktime
        " autocmd CursorMovedI    * silent! checktime
    endif
augroup END

ab asap as soon as possible
ab ptal please take another look
