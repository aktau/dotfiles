" some distros linux distros set filetype in /etc/vimrc
filetype off
filetype plugin indent off

set nocompatible               " be iMproved
set nomodeline

if has('mac')
  " fix clipboard on osx, do note that when running from within tmux, you
  " might need something like
  " https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard
  set clipboard+=unnamed
else
  set clipboard=unnamedplus
endif

" Install vim-plug if it's missing. Need curl(1) though.
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

" Say no to Python. On Neovim it spawns an extra process and is generally slow.
if has('nvim')
  let g:loaded_python_provider = 0
  let g:loaded_python3_provider = 0
endif

" PlugActivated is a cut-down version of PlugLoaded
" (https://vi.stackexchange.com/a/14143), which only checks for whether a plugin
" will be loaded. So it can be used at load-time itself to decide whether or not
" to load an extra plugin based on other plugins being activated.
function! PlugActivated(name)
  return (
    \ has_key(g:plugs, a:name) &&
    \ isdirectory(g:plugs[a:name].dir))
endfunction

" Conditional activation of plugins by predicates.
function! PlugCond(cond, ...)
  let opts = get(a:000, 0, {})
  return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

" A list of known paths on remote filesystems. It would be more futureproof to
" interpret the output of df(1), but I'm lazy and it sounds error-prone.
let g:fs_remote_folders = []

call plug#begin('~/.vim/bundle')

let mapleader = ","

" Enable any local modifications (part 1).
if filereadable($HOME . '/.local_config/local.vim')
  source ~/.local_config/local.vim
endif

if has('nvim')
  " LSP extras. The actual setup is just based on native nvim functions, see
  " .vim/lua/lsp.lua.
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/nvim-cmp' " Async autocomplete using nvim builtin LSP.
  Plug 'hrsh7th/vim-vsnip' " A snippet plugin is required for hrsh7th/nvim-cmp.
endif

" original repos on github
Plug 'b4winckler/vim-angry'
Plug 'godlygeek/tabular'
if has('nvim')
  Plug 'nvim-lualine/lualine.nvim'
  Plug 'arkav/lualine-lsp-progress'
else
  Plug 'itchyny/lightline.vim'
endif
Plug 'junegunn/fzf'  " This downloads the whole FZF repo even if we only want fzf.vim, so bet it.
Plug 'luochen1990/rainbow'
Plug 'mhinz/vim-signify'
Plug 'rhysd/clever-f.vim'
Plug 'roman/golden-ratio'
Plug 'sgur/vim-editorconfig'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive', PlugCond(empty(filter(copy(g:fs_remote_folders), {_, dir -> getcwd() =~ '^' . dir})))
Plug 'tpope/vim-repeat'
" Plug 'tpope/vim-sleuth' " See https://github.com/tpope/vim-sleuth/issues/74
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'xuhdev/SingleCompile'

" themes (only uncomment the ones I use frequently, to pollute rtp less)
" Plug 'AhmedAbdulrahman/aylin.vim'
" Plug 'Rigellute/rigel'
" Plug 'arcticicestudio/nord-vim'
" Plug 'drewtempelmeyer/palenight.vim'
" Plug 'gruvbox-community/gruvbox'
" Plug 'lifepillar/vim-solarized8'
Plug 'mhartington/oceanic-next'
Plug 'robertmeta/nofrils'
" Plug 'sainnhe/sonokai'

" language support
Plug 'exu/pgsql.vim'
Plug 'google/vim-jsonnet'
Plug 'mmarchini/bpftrace.vim'
Plug 'nfnty/vim-nftables'
Plug 'rodjek/vim-puppet'
Plug 'rust-lang/rust.vim'

call plug#end()

filetype plugin indent on         " load file type plugins + indentation
syntax enable

set encoding=utf-8
scriptencoding utf-8

set showcmd                       " display incomplete commands.
set showmode                      " display the mode you're in.
set showmatch                     " show matching brackets/parenthesis
set mat=5                         " duration to show matching tabs
set autoread                      " reload files automagically

" text preferences
set nowrap                        " don't wrap lines
set tabstop=2 shiftwidth=2 softtabstop=2 nosmarttab expandtab
set backspace=indent,eol,start    " backspace through everything in insert mode"
set autoindent                    " match indentation of previous line
set textwidth=80                  " in new gvim windows
set colorcolumn=+1                " Set colorcolumn = textwidth + 1.
set formatoptions+=n              " format numbered lists properly
set nojoinspaces                  " Don't add extra spaces after join/fmt.

" show invisible characters
set list
" some alternatives: tab:▸\,eol:¬
set listchars=tab:▸\ ,trail:…

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

" undo
set noundofile                    " Don't save undo's after file closes.

set hidden                        " Handle multiple buffers better.
set title                         " Set the terminal's title, see https://github.com/neovim/neovim/issues/19040
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
set shell=/bin/zsh
set diffopt+=vertical             " Vertical diff windows on :diffsplit.

set visualbell
set noerrorbells
set history=1000                  " Store lots of :cmdline history

set splitbelow
set splitright

set scrolloff=3
set sidescrolloff=7
set sidescroll=1                  " Number of columns to scroll horizontally.
set mouse=                        " Disable mouse (allows copying from cmdline).
set mousehide
if exists("+inccommand")
  set inccommand=nosplit
endif

set nobackup                      " Don't make a backup before overwriting a file.
set nowritebackup                 " And again.
set directory=/tmp                " Keep swap files in one location
set noswapfile
set timeoutlen=500
" Trigger CursorHold after 500ms (default is 4000ms). This used to be 100ms, but
" e.g. vim-signify checks whether files on disk have changed based on this
" interval (plus cursor move). Alternatively we could go back to 100ms and
" disable vim-signify auto-update. This would allow the snappy experience of the
" nvim-lsp diagnostic popup again.
set updatetime=500

" Vim 8 and Neovim have libxdiff built-in, and can be told to use the patience
" algorithm, which I like better.
"
" Sadly, the patch-level check doesn't wor for Neovim because it remains at
" minor patchlevel 0 (meaning it doesn't consider any Vim 8.1 patches to be
" integrated).
set diffopt+=algorithm:patience

set laststatus=2                  " Show the status line all the time

" Use the $COLORTERM environment variable to detect 24-bit colour capability in
" terminals. The Tc bit is a long way from being standardized, and at least with
" an environment variable it's easy for me to override. Some terminals (like
" hterm) set the environment variable themselves, which is nice.
if has('termguicolors') && (&termguicolors || !empty($COLORTERM))
  set termguicolors

  let g:oceanic_next_terminal_bold = 1
  let g:oceanic_next_terminal_italic = 1

  colorscheme OceanicNext
endif

" clear trailing spaces on save
autocmd BufWritePre * kz|:%s/\s\+$//e|'z

autocmd FileType python setlocal tabstop=8 expandtab shiftwidth=4 softtabstop=4

" indent/unindent visual mode selection with tab/shift+tab
vmap <tab> >gv
vmap <s-tab> <gv

" Prefer :tjump over :tag, see https://stackoverflow.com/q/7640663/558819.
nnoremap <c-]> g<c-]>
vnoremap <c-]> g<c-]>
" Open the definition (using :tjump, due to 'g') in a vertical split (<c-w>g).
"
" This is the vertical version of <c-w>g<c-]>, except that this has the downside
" of opening a split even if the tag can't be found. To fix this, we might
" formulate it in Ex-commands instead:
"
"   nnoremap <C-\> :vertical stjump <C-r><C-w><CR>
"                                   ^^^^^^^^^^
"                                        `--- Word under cursor :h c_<C-R>_<C-W>
"
" The problem is that this formulation pases flags '' instead of flags 'c' to
" `:h tag-function`. This means (e.g.) for the Neovim LSP tagfunc, that it
" doesn't actually use go-to-definition. For now I'll live with the downside.
"
" Maybe I'll give the approaches in https://www.reddit.com/r/vim/comments/8vsdmt
" and https://stackoverflow.com/a/563992/558819 a try next.
nnoremap <c-\> <c-w>vg<c-]>
vnoremap <c-\> <c-w>vg<c-]>

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
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" re-select text you just pasted
nnoremap <leader>v V`]

" see what unsaved changes you have
nnoremap <leader>u :w !diff - %<CR>

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

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

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

" vimgrep / ripgrep
"
" Try to use the native grep functionality instead of the emulation that
" improves upon :grep here written down by romainl@ [1]. I think we can probably
" fix this in Neovim. I have some CLs lined up, to avoid temporary files,
" sub-shells and spurious I/O. Now that the refactor of replace_makeprg is in
" (https://github.com/neovim/neovim/issues/19570) I can even get rid of one of
" my spurious commits.
"
" For now, typing <leader>g is fairly OK.
"
" TODO: Perhaps integrate
"       https://vi.stackexchange.com/questions/8855/how-can-i-change-the-default-grep-call-grepprg-to-exclude-directories.
"
" [1]: https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3
if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
nnoremap <leader>g :silent lgrep!
" :Grep - search and then open the window
" Source: https://vonheikemen.github.io/devlog/tools/vim-and-the-quickfix-list
" command! -nargs=+ Grep execute 'silent grep! <args>' | copen

" Open the quickfix/loclist window automatically when it is filled.
augroup qf
  autocmd!

  " Do :cwindow if a quickfix-filling command was used (no prefix, :grep), or
  " :lwindow if a location-filling command was used (:lgrep, ...).
  autocmd QuickFixCmdPost [^l]* cwindow
  autocmd QuickFixCmdPost l*    lwindow
augroup END

""""""""""""""""""""""
" plugin customization
""""""""""""""""""""""

if has('nvim')
  " nvim-lsp
  lua require('lsp')

  " lualine.nvim
  lua << END
  -- Remove when https://github.com/arkav/lualine-lsp-progress/issues/10 is
  -- fixed.
  local function lsp_client_names()
    local clients = {}
    for idx, client in pairs(vim.lsp.buf_get_clients()) do
      clients[idx] = client.name
    end
    if next(clients) == nil then
      return ""
    end
    return "LSP(" .. table.concat(clients, "/") .. ")"
  end
  require("lualine").setup({
    options = {
      icons_enabled = false,
      component_separators = { left = '|', right = '|'},
      section_separators = { left = '', right = ''},
    },
    sections = {
      lualine_a = {"mode"},
      lualine_b = {"branch", "diff", {"diagnostics", sources = { "nvim_diagnostic" }}},
      lualine_c = { { "filename", path = 1 }, lsp_client_names, "lsp_progress" },
      lualine_x = {"encoding", "fileformat", "filetype"},
      lualine_y = {"progress"},
      lualine_z = {"location"}
    },
  })
END
else
  " lightline
  let g:lightline = {
    \   'active': {
    \     'left': [ [ 'mode', 'paste' ],
    \               [ 'fugitive', 'readonly', 'relativepath', 'modified' ] ]
    \   },
    \   'component_function': {
    \     'fugitive': 'fugitive#statusline',
    \   }
    \ }
endif

" vim-signify
let g:signify_sign_change = '~'              " The default is '!', but I prefer vim-gitgutter's '~'

" SingleCompile
nnoremap <leader>r :SCCompileRun<cr>

" rust.vim
let g:rustfmt_autosave = 1
" Rust uses textwidth=99, to disable this, use let g:rust_recommended_style = 0.
" Otherwise adjust colorcolumn to match.
au FileType rust setlocal colorcolumn=100

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

" rainbow
let g:rainbow_active = 0 " Disabled by default, toggle with :RainbowToggle.
map <F4> :RainbowToggle<CR>

""""""""""""""""""""
" filetype detection
""""""""""""""""""""

if has('nvim')
  "`Highlight text on (non-visual mode) yanking.
  augroup highlightyank
    au!
    au TextYankPost * lua require('vim.highlight').on_yank{timeout=500, on_visual=false}
  augroup END
endif

au WinEnter * setlocal cursorline
au WinLeave * setlocal nocursorline
au VimResized * wincmd = " Resize splits on window resize.
hi ExtraWhitespace ctermbg=red guibg=red
au ColorScheme * hi ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$\| \+\ze\t/

" This is a modified version of the formatlistpat found in the Markdown
" filetype, and the default formatlistpat. The goal is to be able to gq all text
" without messing things up.
let s:listpatterns =  []
let s:listpatterns += ['^\s*\d\+[\]:.)]\s\+']      " 1. ... (with . = :.)] etc.)
let s:listpatterns += ['^\s*[-*+•]\s\+']           " - ...
let s:listpatterns += ['^\s*\[\d\+\]:\?\s*']       " [1]: ...
let s:listpatterns += ['^\s*TODO[(][^)]\+[)]:\s*'] " TODO(me): ...
let s:listpatterns += ['^\s*TODO:\s*']             " TODO: ...
let &l:formatlistpat = join(s:listpatterns, '\|')
au FileType * let &formatlistpat=join(s:listpatterns, '\|')

" C-language family options.
au FileType c,cpp,go set formatoptions+=roj

" C file specific options
au FileType c,cpp set cindent
au FileType c,cpp setlocal comments^=:///
" No C++ codebase I work on uses old-style /* */ comments.
au FileType cpp   setlocal commentstring=//\ %s

au FileType javascript setlocal nocindent

" Only set the filetype of *.sql files to pgsql if it has been set to 'sql'
" before. To avoid overwriting earlier autocmds peculiar to a local config.
au BufRead,BufNewFile *.sql if !exists("g:filetype_sql") | set ft=pgsql | endif
au BufRead,BufNewFile *.svg set ft=svg
au BufRead,BufNewFile *.dasc set ft=c
au BufRead,BufNewFile mutt{ng,}-*-\w\+ set ft=mail

" Go file specific options
" Hide tab characters (normally they're highlighted using listchars). Note that
" removing the `tab:...` part from listchars just makes it highlighted using the
" default (^I), which is even more ugly.
au FileType go setlocal listchars=tab:\ \ ,trail:…

" tries to get buffer reloading to work correctly in terminals
"
" Remove this is if https://github.com/neovim/neovim/issues/1380 is ever fixed.
augroup checktime
  au!
  if !has("gui_running")
    " silent! necessary otherwise throws errors when using command
    " line window.
    autocmd BufEnter,CursorHold,CursorHoldI * silent! checktime
  endif
augroup END

" Enable any local modifications (part 2).
if filereadable($HOME . '/.local_config/local.after.vim')
  source ~/.local_config/local.after.vim
endif
