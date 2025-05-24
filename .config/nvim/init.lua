vim.scriptencoding = "utf-8"

-- Speedup lua module loading.
vim.loader.enable()

-- Disable unused providers
vim.g.loaded_node_provider    = 0
vim.g.loaded_perl_provider    = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_python_provider  = 0
vim.g.loaded_ruby_provider    = 0

-- Disable unused builtin plugins.
vim.g.loaded_gzip             = 0
vim.g.loaded_matchit          = 0 -- Superseded by andymass/vim-matchup.
vim.g.loaded_matchparen       = 0 -- Superseded by andymass/vim-matchup.
vim.g.loaded_netrwPlugin      = 0
vim.g.loaded_remote_plugins   = 0
vim.g.loaded_tarPlugin        = 0
vim.g.loaded_tohtml           = 0
vim.g.loaded_tutor            = 0
vim.g.loaded_zipPlugin        = 0

-- core
vim.opt.shell                 = "/bin/zsh" -- zsh is my preferred shell.
vim.opt.shellcmdflag          = "-fc"      -- Add "-f" to inhibit loading of .zshenv, speeds things up.
vim.opt.undofile              = false      -- Don't save undo's after file closes.
vim.opt.backup                = false      -- Don't make a backup before overwriting a file.
vim.opt.writebackup           = false      -- And again.
vim.opt.swapfile              = false      -- Disable swap.
vim.opt.timeoutlen            = 500        -- Msec to wait for mapped sequence completion.
vim.opt.clipboard             = "unnamedplus"
vim.opt.modeline              = false      -- Modeline is a security risk, editorconfig is builitin.

-- editing
vim.opt.textwidth             = 80           -- Max column.
vim.opt.colorcolumn           = { vim.o.textwidth + 1 }
vim.opt.formatoptions:append("n")            -- format numbered lists properly
vim.opt.gdefault = true                      -- vim.opt.the global flag on substitute commands by default
vim.opt.matchpairs:append("<:>")             -- Match < and > as well.
vim.opt.wildmode            = "list:longest" -- Complete files like a shell.
vim.opt.wildignore          = {              -- Stuff to ignore when tab completing
  "*.o",
  "*.obj",
  "*.so",
  "*.swp",
  "*.zip",
  "*/.git/objects/*",
  "*/.git/refs/*",
  "*/.hg/*",
  "*/.svn/*",
  "*~",
}
vim.opt.spell               = true -- See https://castel.dev/post/lecture-notes-1.
vim.opt.spelllang           = "en"

-- listpatterns is always buffer-local. Force a good one for every filetype.
local listpatterns          = table.concat({
  [[^\s*\d\+[\]:.)]\s\+]], -- " 1. ... (with . = :.)] etc.)
  [[^\s*[-*+•]\s\+]], -- " - ...
  [[^\s*\[\d\+\]:\?\s*]], -- " [1]: ...
  [[^\s*TODO[(][^)]\+[)]:\s*]], -- " TODO(me): ...
}, [[\|]])
vim.opt_local.formatlistpat = listpatterns
vim.api.nvim_create_autocmd("FileType",
  { pattern = "*", callback = function() vim.opt_local.formatlistpat = listpatterns end })


-- searching
vim.opt.ignorecase  = true    -- Case-insensitive searching.
vim.opt.smartcase   = true    -- But case-sensitive if expression contains a capital letter.
vim.opt.tagcase     = "match" -- Case sensitive tag matching (most langs are cs).

-- ui
vim.opt.completeopt = { "menuone", "noinsert", "noselect", "fuzzy" }
vim.opt.shortmess:append("c") -- Avoid showing extra message when completing.
vim.opt.list          = true -- show invisible characters
vim.opt.listchars     = { tab = "▸ ", trail = "…" } -- some alternatives: tab:▸\,eol:¬
vim.opt.showmatch     = true -- show matching brackets/parenthesis
vim.opt.wrap          = false -- don't wrap lines
vim.opt.tabstop       = 2
vim.opt.shiftwidth    = 2
vim.opt.softtabstop   = 2
vim.opt.smarttab      = false
vim.opt.expandtab     = true
vim.opt.hidden        = true -- Handle multiple buffers better.
vim.opt.title         = true -- vim.opt.the terminal's title, see https://github.com/neovim/neovim/issues/19040
vim.opt.number        = true -- Show line numbers.
vim.opt.cursorline    = true -- Highlight current line
vim.opt.laststatus    = 2    -- Show the status line all the time
vim.opt.visualbell    = true -- Visual bell instead of beeping.
vim.opt.splitbelow    = true -- New window should be below current one.
vim.opt.splitright    = true -- New window should be right of current one.
vim.opt.updatetime    = 500  -- CursorHold after 500s. Used by vim-signify etc.
vim.opt.scrolloff     = 10
vim.opt.sidescrolloff = 7
vim.opt.mouse         = "" -- Disable mouse (allows copying from cmdline).
vim.opt.diffopt       = {
  "vertical",              -- Vertical diff windows on :diffsplit.
  "algorithm:patience",    -- Available since Vim 8 & Neovim
  "inline:word",           -- Highlight differences within a line at word granularity.
  "linematch:50",
  "closeoff",              -- Turn off diff move if either of a split is closed.
}

-- Plugins

-- Download (if needed) and setup mini.deps plugin manager.
local path_package    = vim.fn.stdpath("data") .. "/site/"
local mini_path       = path_package .. "pack/deps/start/mini.nvim"
if not vim.uv.fs_stat(mini_path) then
  vim.cmd([[echo "Installing `mini.nvim`" | redraw]])
  vim.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/echasnovski/mini.deps", mini_path
  }):wait()
  vim.cmd("packadd mini.nvim | helptags ALL")
  vim.cmd([[echo "Installed `mini.nvim`" | redraw]])
end
local mini = {
  deps = require("mini.deps"),
}
mini.deps.setup({ path = { package = path_package } })

do -- Colorscheme (eager due to affecting the UI).
  mini.deps.add({ source = "mhartington/oceanic-next" })

  vim.cmd("colorscheme OceanicNext")
  vim.api.nvim_set_hl(0, "ExtraWhitespace", { ctermbg = "red", bg = "red", force = true })
end

do -- lualine.nvim (eager due to affecting the UI)
  mini.deps.add({ source = "nvim-lualine/lualine.nvim", })
  mini.deps.add({ source = "arkav/lualine-lsp-progress", depends = { "nvim-lualine/lualine.nvim" } })

  local function lsp_client_names()
    local clients = {}
    for idx, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
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
      component_separators = { left = "|", right = "|" },
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", { "diagnostics", sources = { "nvim_diagnostic" } } },
      lualine_c = { { "filename", path = 1 }, lsp_client_names, "lsp_progress" },
      lualine_x = { "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" }
    },
  })
end

do -- vim-signify (eager due to installing autocommands)
  mini.deps.add({ source = "mhinz/vim-signify" })

  vim.g.signify_sign_change = "~" -- The default is "!", but I prefer vim-gitgutter's "~"
end

-- Filetypes. Eager due to adding autocommands.
mini.deps.add({ source = "google/vim-jsonnet" })
mini.deps.add({ source = "mmarchini/bpftrace.vim" })
mini.deps.add({ source = "nfnty/vim-nftables" })

-- Eager due to installing autocommands (setup happens later).
mini.deps.add({ source = "andymass/vim-matchup" })
mini.deps.add({ source = "nvim-treesitter/nvim-treesitter", hooks = { post_checkout = function() vim.cmd("TSUpdate") end } })
mini.deps.add({ source = "nvim-treesitter/nvim-treesitter-context", depends = { "nvim-treesitter/nvim-treesitter" } })
mini.deps.add({ source = "nvim-treesitter/nvim-treesitter-textobjects", depends = { "nvim-treesitter/nvim-treesitter" } })

-- Key mappings
vim.g.mapleader = ","
--
-- A list of known paths on remote filesystems. It would be more futureproof to
-- interpret the output of df(1), but I'm lazy and it sounds error-prone.
vim.g.fs_remote_folders = {}

local function sourcefile(fname)
  if vim.uv.fs_stat(fname) then
    dofile(fname)
  end
end

sourcefile(vim.env.HOME .. "/.local_config/nvim.init.pre.lua")

-- Mappings.
mini.deps.later(function()
  -- Make split navigation easier, in normal and terminal mode.
  vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "move to split on the left" })
  vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "move to split below" })
  vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "move to split above" })
  vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "move to split on the right" })

  vim.keymap.set("t", "<C-h>", [[<C-\><C-N><C-w>h]], { desc = "move to split on the left" })
  vim.keymap.set("t", "<C-j>", [[<C-\><C-N><C-w>j]], { desc = "move to split below" })
  vim.keymap.set("t", "<C-k>", [[<C-\><C-N><C-w>k]], { desc = "move to split above" })
  vim.keymap.set("t", "<C-l>", [[<C-\><C-N><C-w>l]], { desc = "move to split on the right" })

  -- Map escape to go into terminal mode.
  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "go to terminal mode" })

  vim.keymap.set("n", "<leader>v", "V`]", { desc = "reselect text you just pasted" })
  vim.keymap.set("n", "<leader>u", [[:w !diff - %<CR>]], { desc = "see unsaved changes in a diff split" })

  -- Go to the end of the copied/yank text.
  vim.keymap.set("x", "y", "y`]", { silent = true, desc = "go to the end of copied text" })
  vim.keymap.set("n", "p", "p`]", { silent = true, desc = "go to the end of pasted text" })

  -- Paste copied text into visual selection without overwriting the current copied
  -- text (so you can past multiple times. Visual mode only (x), not select mode.
  -- Source: ThePrimeagen (https://youtu.be/w7i4amO_zaE?t=1624)
  vim.keymap.set("x", "p", [["_dP]])

  vim.keymap.set("x", ".", [[:norm.<CR>]], { desc = "enable the dot command (repeat) in visual mode" })

  -- Disable the arrow keys.
  vim.keymap.set("n", "<Left>", [[:echo "no!"<cr>]])
  vim.keymap.set("n", "<Right>", [[:echo "no!"<cr>]])
  vim.keymap.set("n", "<Up>", [[:echo "no!"<cr>]])
  vim.keymap.set("n", "<Down>", [[:echo "no!"<cr>]])

  -- Use <Tab> and <S-Tab> to navigate through popup menu.
  vim.keymap.set("i", "<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
  vim.keymap.set("i", "<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })

  -- Spelling
  --
  -- Mark current cursor position, naming it s (ms). Move to first spelling error
  -- before the current position ([s,), fix it with the first suggestion (1z=),
  -- highlight the fixed word in a hacky way (*), then move back (`s).
  vim.keymap.set("n", "[gs", [[ms[s1z=*`s]], { desc = "fix nearest spelling error on the left" })
  vim.keymap.set("n", "]gs", [[ms]s1z=*`s]], { desc = "fix nearest spelling error on the right" })

  -- Searching. Clear highlight on return. Default to magic.
  vim.keymap.set("n", "<CR>", ":nohlsearch<CR><CR>", { silent = true })
  vim.keymap.set({ "n", "x" }, "/", "/\\v")

  -- Indent/unindent visual mode selection with tab/shift+tab.
  vim.keymap.set("x", "<tab>", [[>gv]], { remap = true })
  vim.keymap.set("x", "<s-tab>", [[>gv]], { remap = true })

  -- Shift visual selection up/down with J/K, while re-indenting.
  -- Source: ThePrimeagen (https://youtu.be/w7i4amO_zaE?t=1555)
  vim.keymap.set("x", "J", [[:m ">+1<CR>gv=gv]], { desc = "shift visual selection up (+ reindent)" })
  vim.keymap.set("x", "K", [[:m "<-2<CR>gv=gv]], { desc = "shift visual selection down (+ reindent)" })

  -- Tags. Prefer :tjump ([g<c-]>) over :tag (<c-]>). See
  -- https://stackoverflow.com/q/7640663/558819. For <c-\>, the downside of
  -- <c-w>vg<c-]> is that it open a split even if the tag can't be found. To fix
  -- this, we might formulate it in Ex-commands instead:
  --
  --   nnoremap <C-\> :vertical stjump <C-r><C-w><CR>
  --                                   ^^^^^^^^^^
  --                                        `--- Word under cursor :h c_<C-R>_<C-W>
  --
  -- The problem is that this formulation passes flags "" instead of flags "c"
  -- to `:h tag-function`. This means (e.g.) for the Neovim LSP tagfunc, that it
  -- doesn't actually use go-to-definition. For now I'll live with the downside.
  --
  -- Maybe I'll give the approaches in
  -- https://www.reddit.com/r/vim/comments/8vsdmt and
  -- https://stackoverflow.com/a/563992/558819 a try next.
  vim.keymap.set({ "n", "x" }, "<c-]>", "g<c-]>", { desc = "go-to tag" })
  vim.keymap.set({ "n", "x" }, [[<c-\>]], "<c-w>vg<c-]>", { desc = "go-to tag in new split" })

  vim.keymap.set("n", "<leader>q", "gwip", { desc = "rewrap the current paragraph" })
  -- Paragraphs don't work properly inside of comment blocks: use the comment
  -- text object (gc). noremap doesn't work, not sure why.
  vim.keymap.set("n", "<leader>e", "gwgc", { remap = true, desc = "rewrap the current comment block" })

  -- Paste before/after linewise
  vim.keymap.set({ "n", "x" }, "[p", [[<Cmd>exe "iput! " . v:register<CR>]], { desc = "Paste above" })
  vim.keymap.set({ "n", "x" }, "]p", [[<Cmd>exe "iput "  . v:register<CR>]], { desc = "Paste below" })

  if vim.fn.executable("nvr") then
    -- Set the source control systems" editor (e.g.: git commit --amend) to:
    --
    --  1. Open a buffer in the current editing session using `nvr --servername`.
    --  2. Wait until the buffer is deleted (--remote-wait) before returning.
    --  3. Delete the buffer when it is closed (bufhidden=wipe).
    local editor = [[nvr -cc split --remote-wait +"setlocal bufhidden=wipe " --servername ]] .. vim.v.servername
    vim.env.HGEDITOR = editor
    vim.env.GIT_EDITOR = editor
    vim.env.P4EDITOR = editor

    -- TODO: auto-detect repository type and reduce to a single mapping.
    --
    -- Use job control instead of `!...`  because these commands need to block, and
    -- their blocking nature prevents Neovim from opening the desired split.
    vim.keymap.set("n", "<leader>ch", function() vim.system({ "hg", "reword" }) end)
    vim.keymap.set("n", "<leader>cg", function() vim.system({ "git", "commit", "--verbose", "--amend" }) end)
    vim.keymap.set("n", "<leader>cc", function() vim.system({ "git", "commit", "--verbose" }) end)
    vim.keymap.set("n", "<leader>cp", function() vim.system({ "p4", "change" }) end)
  end
end)

-- For some reason it's not a good idea to put this in a later block. Likely
-- due to the autocommands.
require("lsp")

-- Plugins that can be lazy-loaded.
mini.deps.later(function()
  -- Plugins without setup.
  mini.deps.add({ source = "roman/golden-ratio" })
  mini.deps.add({ source = "tpope/vim-repeat" })
  mini.deps.add({ source = "tpope/vim-surround" })

  -- Only load fugitive if we're not in a remote folder.
  local cwd = vim.uv.cwd()
  if not vim.iter(ipairs(vim.g.fs_remote_folders)):any(function(_, v) return vim.startswith(cwd, v) end) then
    mini.deps.add({ source = "tpope/vim-fugitive" })
  end

  do -- TreeSitter
    local treesitter_parsers = {
      "c",
      "cpp",
      "go",
      "lua",             -- Want highlighting of lua nested in viml.
      "markdown",        -- Doesn't desync, and supports nested syntaxes (code blocks).
      "markdown_inline", -- Nested syntax support for markdown.
      "sql",             -- Enable highlighted SQL in markdown blocks.
      "starlark",
      "vim",             -- Doesn't desync, unlike the regex parser.
      "vimdoc",          -- Vim help.
    }
    require("nvim-treesitter.configs").setup({
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
      -- vim-matchup
      matchup = {
        enable = true,
      },
      -- If at some point this list grows too large, consider moving to
      -- nvim-treesitter-textsubjects.
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]S"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[S"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>sa"] = "@parameter.inner", -- [S]wap next [A]rgument.
          },
          swap_previous = {
            ["<leader>sA"] = "@parameter.inner", -- [S]wap previous [A]rgument.
          },
        },
      },
    })
  end

  do -- fzf-lua
    mini.deps.add({ source = "ibhagwan/fzf-lua" })

    mini.deps.later(function()
      require("fzf-lua").setup({
        defaults = {
          -- Setting the following to false leads to better performance. It
          -- enables the "native" mode (no interposition) even when the
          -- non-native variants (e.g.: live_grep) are executed.
          file_icons = false,
          git_icons = false,
        },
        grep = {
          rg_glob = false, -- Inhibits native mode, and I never use it.
        },
        fzf_colors = {
          true, -- It looks ugly without this.
        },
      })

      -- Override |vim.ui.select|. See
      -- https://github.com/ibhagwan/fzf-lua/wiki#automatic-sizing-of-heightwidth-of-vimuiselect.
      require("fzf-lua").register_ui_select(function(_, items)
        local min_h, max_h = 0.15, 0.70
        local h = (#items + 4) / vim.o.lines
        if h < min_h then
          h = min_h
        elseif h > max_h then
          h = max_h
        end
        return { winopts = { height = h, width = 0.60, row = 0.40 } }
      end)
    end)

    vim.keymap.set("n", "<c-p>", function() require("fzf-lua").files() end, { desc = "fuzzy find files" })
    vim.keymap.set("n", "<c-g>", function() require("fzf-lua").live_grep() end, { desc = "fuzzy live grep" })
    vim.keymap.set("n", "<c-f>", function() require("fzf-lua").helptags() end, { desc = "fuzzy help tags" }) --Regrettably c-h is already taken by split nav.
    vim.keymap.set("n", "<m-p>", function() require("fzf-lua").commands() end, { desc = "fuzzy command palette" })
    vim.keymap.set("n", "<m-k>", function() require("fzf-lua").keymaps() end, { desc = "fuzzy keymaps" })
    vim.keymap.set("n", "<m-h>", function() require("fzf-lua").command_history() end, { desc = "fuzzy command history" })
    vim.keymap.set({ "n", "v", "i" }, "<C-x><C-f>", function() require("fzf-lua").complete_path() end,
      { desc = "fuzzy complete path" })
  end

  do -- flash.nvim
    mini.deps.add({ source = "folke/flash.nvim" })
    require("flash").setup({
      modes = {
        -- Disable search integration. Better to use "s" if I want flash search.
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
    vim.keymap.set({ "n", "x" }, "s", function() require("flash").jump() end, { desc = "Flash" })
    vim.keymap.set({ "n", "x" }, "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
    vim.keymap.set({ "o" }, "r", function() require("flash").remote() end, { desc = "Remote Flash" })
    vim.keymap.set({ "o", "x" }, "R", function() require("flash").treesitter_search() end, { desc = "Treesitter Search" })
  end

  do -- mini.align
    mini.deps.add({ source = "echasnovski/mini.align" })
    mini.align = require("mini.align")
    mini.align.setup({
      mappings = {
        start = "<leader>a",
        start_with_preview = "<leader>A",
      },
      -- Default options controlling alignment process.
      steps = {
        pre_justify = { mini.align.gen_step.trim("both", "keep") }
      },
    })
  end
end)

-- Autocommands
vim.api.nvim_create_autocmd("BufWritePre",
  { pattern = "*", command = [[kz|:%s/\s\+$//e|'z]], desc = "clear trailing spaces on save" })

vim.api.nvim_create_autocmd("FileType", { pattern = { "c", "cpp" }, command = [[set cindent ]] })
vim.api.nvim_create_autocmd("FileType", { pattern = { "c", "cpp" }, command = [[setlocal comments^=:///]] })
vim.api.nvim_create_autocmd("FileType", { pattern = { "c", "cpp", "go" }, command = [[setlocal formatoptions+=roj]] })
vim.api.nvim_create_autocmd("FileType", { pattern = { "cpp" }, command = [[setlocal commentstring=//\ %s]] })
vim.api.nvim_create_autocmd("FileType",
  { pattern = { "gitcommit" }, command = [[setlocal textwidth=72]], desc = "gerrit wraps at 72 characters" })
vim.api.nvim_create_autocmd("FileType", { pattern = { "go" }, command = [[setlocal listchars=tab:\ \ ,trail:…]] })
vim.api.nvim_create_autocmd("FileType",
  { pattern = { "python" }, command = [[setlocal tabstop=8 expandtab shiftwidth=4 softtabstop=4]] })

-- Open items from the quickfix window in a new vertical split with ctrl-v.
--
-- Source: https://stackoverflow.com/a/49345500
local function open_quickfix_in_split()
  -- 1. Determine whether we're in a location list or quickfix window.
  --    Approach adopted from vim-unimpaired.
  local win = vim.fn.getwininfo(vim.fn.win_getid())[1]
  -- 2. the current line is the result idx as we are in the quickfix.
  local qf_idx = vim.fn.line(".")
  -- 3. jump to the previous window.
  vim.cmd("wincmd p")
  -- 4. switch to a new split.
  vim.cmd("vnew")
  -- 5. open the "current" item of the quickfix or loclist list in the newly
  --    created buffer (the current means, the one focused before switching to
  --    the new buffer)
  vim.cmd(("%s%s"):format(qf_idx, win.loclist == 1 and "ll" or "cc"))
end
vim.api.nvim_create_autocmd("FileType",
  { pattern = { "qf" }, callback = function() vim.keymap.set("n", "<C-v>", open_quickfix_in_split, { buffer = true }) end })


vim.api.nvim_create_autocmd("WinEnter", { pattern = "*", command = [[setlocal cursorline]] })
vim.api.nvim_create_autocmd("WinLeave", { pattern = "*", command = [[setlocal nocursorline]] })

vim.api.nvim_create_autocmd("VimResized",
  { pattern = "*", command = [[wincmd=]], desc = "resize splits on window resize." })

vim.api.nvim_create_autocmd("TextYankPost",
  { pattern = "*", callback = function() vim.hl.on_yank({ timeout = 500, on_visual = false }) end })

-- Open the quickfix/loclist window automatically when it is filled.
vim.api.nvim_create_autocmd("QuickFixCmdPost",
  { pattern = { "[^l]*" }, command = [[cwindow]], desc = "open quickfix window if filled" })
vim.api.nvim_create_autocmd("QuickFixCmdPost",
  { pattern = { "l*" }, command = [[lwindow]], desc = "open location window if filled" })

sourcefile(vim.env.HOME .. "/.local_config/nvim.init.post.lua")
