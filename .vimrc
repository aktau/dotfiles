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
Plug 'ajh17/VimCompletesMe'
Plug 'b4winckler/vim-angry'
Plug 'chrisbra/vim-diff-enhanced'
Plug 'sgur/vim-editorconfig'
Plug 'godlygeek/tabular'
Plug 'itchyny/lightline.vim'
Plug 'ludovicchabant/vim-gutentags'
Plug 'luochen1990/rainbow'
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
Plug 'rust-lang/rust.vim'

let mapleader = ","
" Enable any local modifications
if filereadable($HOME . '/.local_config/local.vim')
  source ~/.local_config/local.vim
endif

" If the local overrides didn't load vim-signify, load gitgutter.
if !exists('g:loaded_signify')
  Plug 'airblade/vim-gitgutter'
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
set textwidth=80                  " in new gvim windows
set colorcolumn=+1                " Set colorcolumn = textwidth + 1.
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
set tagcase=match                 " Case sensitive tag matching (most langs are cs).
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
set wildignore+=*/.git/objects/*
set wildignore+=*/.git/refs/*
set wildignore+=*/.hg/*,*/.svn/*
set wildignore+=*/tmp/*,*.so
set wildignore+=*.swp,*.zip

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
if exists("+inccommand")
  set inccommand=nosplit
endif

set nobackup                      " Don't make a backup before overwriting a file.
set nowritebackup                 " And again.
set directory=/tmp                " Keep swap files in one location
set noswapfile
set timeoutlen=500

set laststatus=2                  " Show the status line all the time

" Set a colorscheme. This is really stupid though, static_tomorrownight changes
" some values. Then changing the background changes the colorscheme back to the
" default (because g:colors_name in static_tomorrownight doesn't match the name
" of the file). This results in something I find pleasant to use. Removing the
" colorscheme invocation should work, but there are apparently some things the
" default scheme doesn't override which I like.
set t_Co=256                      " Set terminal to 256 colors
colorscheme static_tomorrownight
set background=dark

autocmd FileType python setlocal tabstop=8 expandtab shiftwidth=4 softtabstop=4

" clear trailing spaces on save
autocmd BufWritePre * kz|:%s/\s\+$//e|'z

" indent/unindent visual mode selection with tab/shift+tab
vmap <tab> >gv
vmap <s-tab> <gv

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

" Rewrap the current paragraph.
nnoremap <leader>q gqip
" Rewrap the current comment block. Necessary because paragraphs don't work
" properly inside of comment blocks, so we re-use tpope's comment block text
" object. nnoremap doesn't work. I have _no_ idea why, maybe because gc isn't
" builtin?. It appears to set a cursor to the end of the block, which I fix with
" marks. Overrides mark `q`, which I hope I wasn't using. Normally I'd use the
" `'` mark but that gets overriden during the `gc` movement, probably because of
" a jump.
nmap <leader>e mjgqgc`j
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

" Terminal mode config (Neovim)

if has('nvim')
  " Map escape to go into terminal mode.
  tnoremap <Esc> <C-\><C-n>

  " Make navigation into and out of terminal splits nicer.
  tnoremap <C-h> <C-\><C-N><C-w>h
  tnoremap <C-j> <C-\><C-N><C-w>j
  tnoremap <C-k> <C-\><C-N><C-w>k
  tnoremap <C-l> <C-\><C-N><C-w>l
endif

""""""""""""""""""""""
" plugin customization
""""""""""""""""""""""

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

" Don't perform syntastic check when we intend to quit (even if we write).
let g:syntastic_check_on_wq = 0

" vim-gutentags
let g:gutentags_enabled = 1
let g:gutentags_generate_on_missing = 1      " Generate a tags file if there is none.
let g:gutentags_generate_on_new = 0          " Don't regenerate tags file in a new Vim session (I tend to reopen Vim a lot).
let g:gutentags_generate_on_write = 1        " Do update the tags file on file save.
let g:gutentags_resolve_symlinks = 1
" Only index tags in git projects. Store tags files inside of the .git
" repository so it doesn't make the repo dirty if 'tags' is missing from
" .gitignore. Downside: this doesn't work for non-git repositories. I would
" enable it for other VCS's as well but I haven't found how to
" conditionalize the '.git' in gutentags_ctags_tagfile...
let g:gutentags_ctags_tagfile = '.git/tags'
let g:gutentags_project_root = ['.git']
let g:gutentags_add_default_project_roots = 0
" Make ctags add the language of the tag, so that we can postprocess the
" tags file for fuzzy tag finding.
let g:gutentags_ctags_extra_args = ['--fields=+l']

" SingleCompile
nnoremap <leader>r :SCCompileRun<cr>

" vim-go
let g:go_auto_sameids = 1         " Auto highlight the same variable.
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_fmt_command = "goimports"

" rust.vim
let g:rustfmt_autosave = 1
" Rust uses textwidth=99, to disable this, use let g:rust_recommended_style = 0.
" Otherwise adjust colorcolumn to match.
au FileType rust setlocal colorcolumn=100
au FileType rust let g:syntastic_rust_checkers = ['rustc']

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
nnoremap <silent> <c-p> :FZF<CR>

if has('lambda')
  " Fuzzy tag searching with FZF. Credit goes to junegunn, slightly modified
  " by me to also take input from concatenated taglist() output.
  function! s:fzftags_sink(line)
    let parts = split(a:line, '\t\zs')
    let excmd = matchstr(parts[2:], '^.*\ze;"\t')
    " If the last match didn't work, that probably means the ex command was
    " already preprocessed (i.e.: it came from taglist()).
    if empty(excmd)
      let excmd = parts[2]
    endif
    " Open the file we want to jumpt to.
    execute 'silent e' parts[1][:-2]
    let [magic, &magic] = [&magic, 0]
    " Jump inside of the file.
    execute excmd
    let &magic = magic
  endfunction

  " Mapping table for Vim &filetype to ctags languages. Note that ctags
  " recognizes .c files as C, while .h files are always C++.
  let s:vim_to_ctags = {
  \   'cpp': '(C|C++)',
  \   'cs': 'C#',
  \ }

  " Fuzzy tag matching. If passed a word as an argument, it will look for a
  " prefix match and present an fzf selector if there are multiple. If no
  " arguments are passed, it will pipe all tags for the current &filetype to
  " fzf. Taken from ivalkeen/vim-ctrlp-tjump and modified. Thanks!
  "
  " Requires Vim 8 or Neovim, as it uses lambdas.
  function! s:fzftags(...)
    if empty(tagfiles())
      echohl WarningMsg
      echom 'No tags file(s) present'
      echohl None
      return
    endif

    " Take the first argument of the function as the (partial) tag to search
    " for if it was given. Otherwise (attempt to) expand the word under the
    " cursor
    let word = exists('a:1') ? a:1 : expand('<cword>')

    " Get the ctags name for the language from &filetype. If we don't have a
    " match in our match, make a good guess by capitalizing the first
    " character of the &filetype.
    let ctagsft = get(s:vim_to_ctags, &filetype, substitute(&filetype, '^.', '\u\0', ''))

    " If was no word was passed as an argument (or was under the cursor), use
    " the entire tags file for fuzzy matching (filtered by filetype).
    if empty(word)
      " Concatenate all existing tagfiles, filtering out lines that don't
      " correspond to our filetype/language. This will implicitly filter out
      " ctags headers as well, so we don't need an extra grep(1) invocation
      " for that.
      "
      "  TODO: Need to canonicalize the filename before attempting to :edit
      "  it (if we go through the tag codepaths Vim canonicalizes them for
      "  us, that's not the case here).
      call fzf#run({
      \ 'source':  'cat '.join(map(tagfiles(), 'fnamemodify(v:val, ":S")')) .
      \            '| grep "language:' . ctagsft . '\t"',
      \ 'options': '+m -d "\t" --with-nth 1,3,2 -n 1,2 --tiebreak=index',
      \ 'down':    '30%',
      \ 'sink':    funcref('s:fzftags_sink')})
      return
    endif

    " For fast tag lookup, we ask for a prefix match. This should enable
    " binary search (help :tagbsearch).
    let taglist = taglist('^' . word)
    if len(taglist) == 0
      echo("No tags found for: " . word)
    elseif len(taglist) == 1
      call feedkeys(":silent! tag " . word . "\r", 'nt')
    else
      " Filter out tags in the taglist that don't match the current filetype.
      let langtaglist = filter(taglist, {key, val -> get(val, 'language') =~ '^'.ctagsft})
      if empty(langtaglist)
        echo("No tags found for: " . word)
        return
      endif
      " ...and pass them to fzf(1).
      call fzf#run({
      \ 'source':  map(langtaglist, {key, val -> get(val, 'name') . "\t" . get(val, 'filename') . "\t" . get(val, 'cmd')}),
      \ 'options': '+m -d "\t" -n 1,2 --tiebreak=index',
      \ 'down':    '30%',
      \ 'sink':    funcref('s:fzftags_sink')})
    endif
  endfunction

  command! -nargs=? FZFTags call s:fzftags(<f-args>)
  nnoremap <c-]> :FZFTags<cr>
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

" rainbow
let g:rainbow_active = 0 " Disabled by default, toggle with :RainbowToggle.
map <F4> :RainbowToggle<CR>

""""""""""""""""""""
" filetype detection
""""""""""""""""""""

au WinEnter * setlocal cursorline
au WinLeave * setlocal nocursorline
au VimResized * wincmd = " Resize splits on window resize.
hi ExtraWhitespace ctermbg=red guibg=red
au ColorScheme * hi ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$\| \+\ze\t/

" C-language family options.
au FileType c,cpp,go set formatoptions+=roj

" This is a modified version of the formatlistpat found in the Markdown
" filetype, and the default formatlistpat. The goal is to be able to gq all text
" without messing things up.
let s:listpatterns =  []
let s:listpatterns += ['^\s*\d\+[\]:.)]\s\+']      " 1. ... (with . = :.)] etc.)
let s:listpatterns += ['^\s*[-*+]\s\+']            " - ...
let s:listpatterns += ['^\s*\[\d\+\]:\?\s*']       " [1]: ...
let s:listpatterns += ['^\s*TODO[(][^)]\+[)]:\s*'] " TODO(me): ...
let s:listpatterns += ['^\s*TODO:\s*']             " TODO: ...
au FileType c,cpp,go,java,lua,gitcommit let &l:formatlistpat=join(s:listpatterns, '\|')

" C file specific options
au FileType c,cpp set cindent
au FileType c,cpp setlocal comments^=:///

au FileType javascript setlocal nocindent

" Only set the filetype of *.sql files to pgsql if it has been set to 'sql'
" before. To avoid overwriting earlier autocmds peculiar to a local config.
au BufRead,BufNewFile *.sql if !exists("g:filetype_sql") | set ft=pgsql | endif
au BufRead,BufNewFile *.svg set ft=svg
au BufRead,BufNewFile *.dasc set ft=c
au BufRead,BufNewFile mutt{ng,}-*-\w\+ set ft=mail

" Go file specific options
au FileType go setlocal makeprg=go\ build
au FileType go setlocal shiftwidth=4 tabstop=4 softtabstop=4 nolist
au FileType go let g:SuperTabDefaultCompletionType = "context"

au FileType go unmap <leader>r
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c :GoCallers<cr>
au FileType go nmap <leader>i <Plug>(go-info)
au FileType go nmap <leader>d <Plug>(go-def)
au FileType go nmap <leader>n <Plug>(go-rename)

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
