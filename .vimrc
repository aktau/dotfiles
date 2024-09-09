scriptencoding utf-8  " Everything hereafter is UTF-8.

" Modeline is a security risk, editorconfig is a better (builtin) alternative.
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
  let g:loaded_node_provider = 0
  let g:loaded_perl_provider = 0
  let g:loaded_python3_provider = 0
  let g:loaded_python_provider = 0
  let g:loaded_ruby_provider = 0
endif

" Conditional activation of plugins by predicates.
function! PlugCond(cond, ...)
  let opts = get(a:000, 0, {})
  return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

" A list of known paths on remote filesystems. It would be more futureproof to
" interpret the output of df(1), but I'm lazy and it sounds error-prone.
let g:fs_remote_folders = []

" Enable Neovim Lua loader. Saves about 10ms (420ms -> 410ms startup time when
" opening a cached file on the remote dir)
"
" $ hyperfine 'nvim swap.go -c q'
if has('nvim')
  lua vim.loader.enable()
endif

call plug#begin('~/.vim/bundle')

let mapleader = ","

" Enable any local modifications (part 1).
if filereadable($HOME . '/.local_config/local.vim')
  source ~/.local_config/local.vim
endif

if has('nvim')
  " LSP extras. The actual setup is just based on native nvim functions, see
  " .vim/lua/lsp.lua.
  Plug 'arkav/lualine-lsp-progress'

  " nvim-telescope
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'

  " lualine
  Plug 'nvim-lualine/lualine.nvim'

  " TreeSitter
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-treesitter/nvim-treesitter-context'
  Plug 'nvim-treesitter/nvim-treesitter-textobjects'

  Plug 'folke/flash.nvim'
endif

" original repos on github
Plug 'godlygeek/tabular'
Plug 'mhinz/vim-signify'
Plug 'roman/golden-ratio'
Plug 'tpope/vim-fugitive', PlugCond(empty(filter(copy(g:fs_remote_folders), {_, dir -> getcwd() =~ '^' . dir})))
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'

" themes (only uncomment the ones I use frequently, to pollute rtp less)
" Plug 'AhmedAbdulrahman/aylin.vim'
" Plug 'Rigellute/rigel'
" Plug 'andersevenrud/nordic.nvim'
" Plug 'drewtempelmeyer/palenight.vim'
" Plug 'gruvbox-community/gruvbox'
" Plug 'lifepillar/vim-solarized8'
Plug 'mhartington/oceanic-next'
" Plug 'robertmeta/nofrils'
" Plug 'sainnhe/sonokai'

" language support
Plug 'google/vim-jsonnet'
Plug 'mmarchini/bpftrace.vim'
Plug 'nfnty/vim-nftables'

call plug#end()

" core
set shell=/bin/zsh
set shellcmdflag=-fc              " Add '-f' to inhibit loading of .zshenv etc.
set noundofile                    " Don't save undo's after file closes.
set nobackup                      " Don't make a backup before overwriting a file.
set nowritebackup                 " And again.
set directory=/tmp                " Keep swap files in one location.
set noswapfile                    " Disable swap.
set timeoutlen=500                " Msec to wait for mapped sequence completion.

" editing
set textwidth=80                  " Max column.
set colorcolumn=+1                " Set colorcolumn = textwidth + 1.
set formatoptions+=n              " format numbered lists properly
set gdefault                      " Set the global flag on substitute commands by default
set matchpairs+=<:>               " Match < and > as well.
set wildmode=list:longest         " Complete files like a shell.
set wildignore=*.o,*.obj,*~       " Stuff to ignore when tab completing
set wildignore+=*/.git/objects/*
set wildignore+=*/.git/refs/*
set wildignore+=*/.hg/*,*/.svn/*
set wildignore+=*.swp,*.zip,*.so
set spell                         " See https://castel.dev/post/lecture-notes-1.
set spelllang=en

" searching
set ignorecase                    " Case-insensitive searching.
set smartcase                     " But case-sensitive if expression contains a capital letter.
set tagcase=match                 " Case sensitive tag matching (most langs are cs).

" ui
set completeopt=menuone,noinsert,noselect,fuzzy
set shortmess+=c                  " Avoid showing extra message when completing.
set list                          " show invisible characters
set listchars=tab:▸\ ,trail:…     " some alternatives: tab:▸\,eol:¬
set showmatch                     " show matching brackets/parenthesis
set nowrap                        " don't wrap lines
set tabstop=2 shiftwidth=2 softtabstop=2 nosmarttab expandtab
set hidden                        " Handle multiple buffers better.
set title                         " Set the terminal's title, see https://github.com/neovim/neovim/issues/19040
set number                        " Show line numbers.
set cursorline                    " Highlight current line
set laststatus=2                  " Show the status line all the time
set visualbell                    " Visual bell instead of beeping.
set splitbelow                    " New window should be below current one.
set splitright                    " New window should be right of current one.
set updatetime=500                " CursorHold after 500s. Used by vim-signify etc.
set scrolloff=10
set sidescrolloff=7
set mouse=                        " Disable mouse (allows copying from cmdline).
set diffopt+=vertical             " Vertical diff windows on :diffsplit.
set diffopt+=algorithm:patience   " Available since Vim 8 & Neovim
if has('nvim')
  set diffopt+=linematch:50
endif

" Ignore URLs (https://vi.stackexchange.com/a/4003). This does not appears to
" work when parsing is treesitter based. See
" https://www.reddit.com/r/neovim/comments/13ewwpw/how_to_disable_spell_checking_based_on_a_regex/).
syntax match UrlNoSpell "\w\+:\/\/[^[:space:]]\+" transparent contained contains=@NoSpell

" Use the $COLORTERM environment variable to detect 24-bit colour capability in
" terminals. The Tc bit is a long way from being standardized, and at least with
" an environment variable it's easy for me to override. Some terminals (like
" hterm) set the environment variable themselves, which is nice.
if has('termguicolors') && !empty($COLORTERM)
  let g:oceanic_next_terminal_bold = 1
  let g:oceanic_next_terminal_italic = 1

  colorscheme OceanicNext
endif

" clear trailing spaces on save
autocmd BufWritePre * kz|:%s/\s\+$//e|'z

autocmd FileType python setlocal tabstop=8 expandtab shiftwidth=4 softtabstop=4

" Edit the hg/git commit message in the current editor in a new split.
"
" Requires Neovim and neovim-remote (the `nvr` command):
"
"   pip3 install --user neovim-remote
"
" Based on the instructions at https://github.com/mhinz/neovim-remote.
if has('nvim') && executable('nvr')
  " Set the source control systems' editor (e.g.: git commit --amend) to:
  "
  "  1. Open a buffer in the current editing session using `nvr --servername`.
  "  2. Wait until the buffer is deleted (--remote-wait) before returning.
  "  3. Delete the buffer when it is closed (bufhidden=wipe).
  let editor = 'nvr -cc split --remote-wait +"setlocal bufhidden=wipe" --servername '.v:servername
  let $HGEDITOR = editor
  let $GIT_EDITOR = editor
  let $P4EDITOR = editor

  " TODO: auto-detect repository type and reduce to a single mapping.
  "
  " Use job control instead of `!...`  because these commands need to block, and
  " their blocking nature prevents Neovim from opening the desired split.
  nnoremap <leader>ch :<C-u>call jobstart(['hg', 'reword'])<CR>
  nnoremap <leader>cg :<C-u>call jobstart(['git', 'commit', '--verbose', '--amend'])<CR>
  nnoremap <leader>cc :<C-u>call jobstart(['git', 'commit', '--verbose'])<CR>
  nnoremap <leader>cp :<C-u>call jobstart(['p4', 'change'])<CR>
endif

" Spelling
"
" Mark current cursor position, naming it s (ms). Move to first spelling error
" before the current position ([s,), fix it with the first suggestion (1z=),
" highlight the fixed word in a hacky way (*), then move back (`s).
nnoremap [gs ms[s1z=*`s
nnoremap ]gs ms]s1z=*`s

" Searching. Clear highlight on return. Default to magic.
nnoremap <CR> :noh<CR><CR>
nnoremap / /\v
xnoremap / /\v

" indent/unindent visual mode selection with tab/shift+tab
vmap <tab> >gv
vmap <s-tab> <gv

" Shift visual selection up/down with J/K, while re-indenting.
" Source: ThePrimeagen (https://youtu.be/w7i4amO_zaE?t=1555)
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

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
nnoremap <leader>q gwip
" Rewrap the current comment block. Necessary because paragraphs don't work
" properly inside of comment blocks, so we re-use the comment text object (gc).
" nnoremap doesn't work, even with the native Neovim text object, not sure why.
nmap <leader>e gwgc

" close the quickfix window
map <leader>qc :cclose<cr>

" Open items from the quickfix window in a new vertical split with ctrl-v.
"
" Source: https://stackoverflow.com/a/49345500
function! <SID>OpenQuickfixInSplit()
  " 1. Determine whether we're in a location list or quickfix window. Approach
  "    adopted from vim-unimpaired.
  let l:win = getwininfo(win_getid())[0]
  " 2. the current line is the result idx as we are in the quickfix.
  let l:qf_idx = line('.')
  " 3. jump to the previous window.
  wincmd p
  " 4. switch to a new split.
  vnew
  " 5. open the 'current' item of the quickfix or loclist list in the newly
  "    created buffer (the current means, the one focused before switching to
  "    the new buffer)
  execute l:qf_idx . (get(l:win, 'loclist') ? 'll' : 'cc')
endfunction

autocmd FileType qf nnoremap <buffer> <C-v> :call <SID>OpenQuickfixInSplit()<CR>

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
xnoremap <silent> y y`]
nnoremap <silent> p p`]

" Paste copied text into visual selection without overwriting the current copied
" text (so you can past multiple times. Visual mode only (x), not select mode.
" Source: ThePrimeagen (https://youtu.be/w7i4amO_zaE?t=1624)
xnoremap p "_dP

" enable the dot command in visual mode
xnoremap . :norm.<CR>

" oh dear... disable the arrow keys
map <Left> :echo "no!"<cr>
map <Right> :echo "no!"<cr>
map <Up> :echo "no!"<cr>
map <Down> :echo "no!"<cr>

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

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
" NOTE: Neovim defaults to ripgrep (rg) if available, since
" https://github.com/neovim/neovim/commit/20b38677c22b0ff19ea54396c7718b5a8f410ed4.
"
" TODO: Perhaps integrate
"       https://vi.stackexchange.com/questions/8855/how-can-i-change-the-default-grep-call-grepprg-to-exclude-directories.
"
" [1]: https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3
nnoremap <leader>g :silent lgrep!

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
  " telescope.nvim

  " ctrl-p: find files.
  nnoremap <silent> <c-p> <cmd>Telescope find_files hidden=true<cr>
  " ctrl-alt-p: find files but don't take .gitignore into account.
  nnoremap <silent> <c-m-p> <cmd>Telescope find_files hidden=true no_ignore=true<cr>
  " Like <leader>g but much more dynamic.
  nnoremap <silent> <c-g> <cmd>Telescope live_grep<cr>
  " Better help tags search. Regrettably c-h is already taken by split nav.
  nnoremap <silent> <c-f> <cmd>Telescope help_tags<cr>
  " Command palette, type alt+p (sadly ctrl+shift+p doesn't seem to work right,
  " ChromeOS intercepts it).
  "
  " TODO: Check out https://github.com/LinArcX/telescope-command-palette.nvim to
  "       define functions only available from the palette.
  nnoremap <silent> <m-p> <cmd>Telescope commands<cr>

  lua << END
  local actions = require("telescope.actions")
  require("telescope").setup({
    defaults = {
      mappings = {
        -- Quite on escape (in insert mode).
        i = {
            ["<esc>"] = actions.close,
            -- Cycle through previous selected prompts.
            ["<C-Down>"] = actions.cycle_history_next,
            ["<C-Up>"] = actions.cycle_history_prev,
        },
      },
    },
  })

  -- nvim-lsp
  require('lsp')

  -- lualine.nvim
  -- Remove when https://github.com/arkav/lualine-lsp-progress/issues/10 is
  -- fixed.
  local function lsp_client_names()
    local clients = {}
    for idx, client in pairs(vim.lsp.get_clients({bufnr = 0})) do
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

  -- nvim-treesitter
  local treesitter_parsers = {
    "c",
    "cpp",
    "go",
    "lua",  -- Want highlighting of lua nested in viml.
    "markdown",  -- Doesn't desync, and supports nested syntaxes (code blocks).
    "markdown_inline",  -- Nested syntax support for markdown.
    "sql",  -- Enable highlighted SQL in markdown blocks.
    "starlark",
    "vim",  -- Doesn't desync, unlike the regex parser.
    "vimdoc",  -- Vim help.
  }
  require('nvim-treesitter.configs').setup({
    -- For now, only do this for languages where markdown is clearly better.
    ensure_installed = treesitter_parsers,
    sync_install = false,
    highlight = {
      enable = true,
      -- Disable for languages that I don't explicitly install, even if the
      -- module is somehow available. Prevent the Christmas tree effect.
      disable = function(lang, bufnr)
        return not vim.tbl_contains(treesitter_parsers, lang)
      end,
      additional_vim_regex_highlighting = false,
    },
    -- If at some point this list grows too large, consider moving to
    -- nvim-treesitter-textsubjects.
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          ["]s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          ["]S"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ["[s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ["[S"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>sa'] = '@parameter.inner', -- [S]wap next [A]rgument.
        },
        swap_previous = {
          ['<leader>sA'] = '@parameter.inner', -- [S]wap previous [A]rgument.
        },
      },
    },
  })

  -- flash.nvim
  require("flash").setup({
    modes = {
      -- Disable search integration. Better to use 's' if I want flash search.
      -- If enabling this, make sure to remove the verymagic rebind
      -- (https://github.com/folke/flash.nvim/issues/278).
      search = {
        enabled = false,
      },
      char = {
        config = function(opts)
          local operator_pending = vim.fn.mode(true):find("no")

          -- autohide flash when in operator-pending mode
          opts.autohide = opts.autohide or operator_pending

          -- disable jump labels when not enabled, when using a count,
          -- or when recording/executing registers or when in operator pending
          -- mode (to save a keystroke, just go to the first match).
          opts.jump_labels = opts.jump_labels
            and vim.v.count == 0
            and vim.fn.reg_executing() == ""
            and vim.fn.reg_recording() == ""
            and not operator_pending
        end,
        -- Make it possible to immediately jump to a far away character with
        -- fFtT without needing to count by showing a jump label over matches.
        jump_labels = true,
      },
    },
    -- Disable the greying out:
    -- https://www.reddit.com/r/neovim/comments/17x01nr/comment/kp23uvf/.
    highlight = {
      backdrop = false,
      groups = {
        backdrop = "",
      }
    },
  })
  -- Don't map in "o" (operator pending) because it conflicts with vim-surround.
  -- Though it would be good to find an alternative as `s` and especially `S` in
  -- operator pending mode sound very powerful.
  vim.keymap.set({"n", "x"}, "s", function() require("flash").jump() end, {desc = "Flash"})
  vim.keymap.set({"n", "x"}, "S", function() require("flash").treesitter() end, {desc = "Flash Treesitter"})
  vim.keymap.set({"o"}, "r", function() require("flash").remote() end, {desc = "Remote Flash"})
  vim.keymap.set({"o", "x"}, "R", function() require("flash").treesitter_search() end, {desc = "Treesitter Search"})
END
endif

" vim-signify
let g:signify_sign_change = '~'              " The default is '!', but I prefer vim-gitgutter's '~'

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

" Vim specific options
" The Vim ftplugin doesn't use a space after the comment character, which makes
" commenting with Neovims native feature annoying, see
" https://github.com/neovim/neovim/pull/28176.
au FileType vim   setlocal commentstring=\"\ %s

" C-language family options.
au FileType c,cpp,go set formatoptions+=roj

" C file specific options
au FileType c,cpp set cindent
au FileType c,cpp setlocal comments^=:///
" No C++ codebase I work on uses old-style /* */ comments.
au FileType cpp   setlocal commentstring=//\ %s

" We override everything to texwidth=80 up above, but git commits really should
" be 72 (anything more messes with Gerrit rendering, for example).
au FileType gitcommit   setlocal textwidth=72

au FileType javascript setlocal nocindent

au BufRead,BufNewFile *.dasc set ft=c

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
