-- for debugging
--  :lua require('vim.lsp.log').set_level("debug")
--  :lua print(vim.inspect(vim.lsp.get_clients({bufnr = 0})))
--  :lua print(vim.lsp.get_log_path())
--  :lua print(vim.inspect(vim.tbl_keys(vim.lsp.callbacks)))

-- Configure diagnostics globally, which also applies to LSP diagnostics via
-- vim.lsp.diagnostic.on_publish_diagnostics.
vim.diagnostic.config({
  severity_sort = true,
  signs = true,             -- Apply signs for diagnostics.
  underline = true,         -- Apply underlines to diagnostics.
  update_in_insert = false, -- Do not update diagnostics while still inserting.
  virtual_text = true,      -- Apply virtual text to line endings.
  float = {
    border = "single",
    header = false,
    scope = "line",
    source = "always",
  }
})

local function path_absolute(filename)
  if filename == nil or filename == "" or string.sub(filename, 1, 1) == '/' then
    return filename
  end
  return vim.uv.fs_realpath(filename)
end

-- Return the first file/dir in `names` found in an upwards traversal (starting
-- at `start`).
local function find_up(start, names)
  return vim.fs.find(names, { path = vim.fs.dirname(start), upward = true })[1]
end

local configs = {
  ["clangd"] = {
    cmd = { "clangd" },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    root_dir = function(fname)
      return vim.fs.dirname(find_up(fname, {
        ".clangd",
        ".clang-tidy",
        ".clang-format",
        "compile_commands.json",
        "compile_flags.txt",
        "configure.ac", -- AutoTools
      })) or vim.fs.dirname(find_up(fname, {
        ".git",
      }))
    end,
  },
  ["gopls"] = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gotmpl" },
    root_dir = function(fname)
      return vim.fs.dirname(find_up(fname, {
        "go.work",
      })) or vim.fs.dirname(find_up(fname, {
        ".git",
      })) or vim.fs.dirname(find_up(fname, {
        "go.mod",
      }))
    end,
    settings = {
      gopls = {
        codelenses = {
          gc_details = true,    -- This is the only lens that defaults to false, enable it.
        },
        usePlaceholders = true, -- Enables placeholders for function parameters or struct fields in completion responses.
        analyses = {
          fieldalignment = true,
          nilness = true,
          shadow = true, -- Check for shadowed variables where the shadowed variable is used in the outer scope afterwards.
          useany = true, -- Check for constraints that could be simplified to "any".
          unusedparams = true,
          unusedwrite = true,
        },
        staticcheck = true, -- Enable extra staticcheck analyzers.
      },
      hints = {
        constantValues = true, -- Shows values for constants (when using iota).
        -- parameterNames = true, -- Show parameter names when calling functions.
      },
    },
  },
  ["efm"] = {
    cmd = { "efm-langserver" },
    filetypes = { "bash", "sh", "zsh" },
    -- Normally root_dir is set to util.root_pattern(".git"). But this means
    -- shellcheck is not enabled for any shell file not in a git repository,
    -- which is not desirable. `root_dir` is required, it servers as an LSP
    -- deduplication point. We only want one EFM so just set it to /.
    root_dir = function() return "/" end,
  },
  ["sumneko_lua"] = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_dir = function(fname)
      return vim.fs.dirname(find_up(fname, {
        ".luarc.json",
        ".luarc.jsonc",
        ".luacheckrc",
        ".stylua.toml",
        "stylua.toml",
        "selene.toml",
        "selene.yml",
      })) or find_up(fname, {
        "lua", -- A lua dir.
      }) or vim.fs.dirname(find_up(fname, {
        ".git",
      })) or os.getenv("HOME")
    end,
    settings = {
      Lua = {
        telemetry = {
          enable = false
        },
        runtime = {
          version = "LuaJIT", -- Neovim uses LuaJIT.
        },
        diagnostics = {
          globals = { "vim" }, -- Global variable in Neovim.
        },
        completion = {
          enable = true,
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true), -- Runtime libs.
          -- Prevent questions about working environment
          -- (https://github.com/neovim/nvim-lspconfig/issues/1700).
          checkThirdParty = false,
        },
      },
    },
  },
}

-- Lookup table of LSP servers by filetype.
local servers_by_filetype = {}

-- Will make `server_name` the _first_ server started for every item in
-- `filetypes`.
local function register_server_for_filetypes(server_name, filetypes)
  -- Prepend `item` to the list (`tbl`), or create the list.
  local function tbl_prepend(tbl, item)
    if tbl == nil then
      return { item }
    end
    table.insert(tbl, 1, item)
    return tbl
  end

  for _, ft in ipairs(filetypes) do
    servers_by_filetype[ft] = tbl_prepend(servers_by_filetype[ft], server_name)
  end
end

for name, config in pairs(configs) do
  register_server_for_filetypes(name, config.filetypes)
end

local override_lsp = vim.g.aktau_override_lsp
if override_lsp ~= nil then
  configs[override_lsp.name] = {
    cmd = override_lsp.cmd,
    filetypes = override_lsp.filetypes,
    -- Only run instances of the remote fs LSP for files that are actually on
    -- the remote fs.
    --
    -- override_lsp_root returns the first matching root from
    -- `g:aktau_override_lsp.roots` that `fname` is a child of, returns nil if
    -- none match.
    root_dir = function(fname)
      -- Early out shortcuts, if either `fname` or `g:aktau_override_lsp.roots`
      -- are empty.
      if fname == nil or fname == '' then
        return nil
      end
      if override_lsp.roots == nil or #override_lsp.roots == 0 then
        return nil
      end

      -- Make path name absolute.
      if string.sub(fname, 1, 1) ~= "/" then
        -- I only know of vim.fn.fnamemodify() or vim.uv.fs_realpath() to
        -- make a relative path absolute. However, the latter requires that the
        -- file actually exists (which isn't always the case): use the former.
        fname = vim.fn.fnamemodify(fname, ":p")
      end

      for _, root_for_override_lsp in ipairs(override_lsp.roots) do
        if vim.startswith(fname, root_for_override_lsp) then
          return root_for_override_lsp
        end
      end

      return nil
    end,
  }

  register_server_for_filetypes(override_lsp.name, override_lsp.filetypes)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

local has_cmp, cmp = pcall(require, 'cmp')
local has_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if has_cmp and has_cmp_nvim_lsp then
  -- The cmp_nvim_lsp.default_capabilities() function takes an "override" table
  -- argument. It is **NOT** used as a base, it just overrides the specific
  -- fields that default_capabilities() would otherwise set. This strangeness
  -- likely works for users because cmp_nvim_lsp is meant to be used with
  -- nvim-lspconfig which by default merges capabilities using tbl_deep_extend,
  -- and always takes make_client_capabilities() as the base since
  -- https://github.com/neovim/nvim-lspconfig/commit/b6d9e427c9fafca5b84a1f429bef4df3ef63244b.
  capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())

  cmp.setup({
    snippet = {
      -- cmp-nvim requires a snippet engine.
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
    }, {
      { name = 'buffer' },
    })
  })
end

local lsp_augroup = vim.api.nvim_create_augroup("lsp", { clear = true })

-- Start a matching LSP client for any of the filetypes owned by the servers in
-- `configs`.
vim.api.nvim_create_autocmd("FileType", {
  group = lsp_augroup,
  pattern = vim.tbl_keys(servers_by_filetype), -- Union of all recognized filetypes.
  callback = function(args)
    local ft = args.match
    local servers = servers_by_filetype[ft]
    for _, server_name in ipairs(servers) do
      -- Start the first LSP in servers_by_filetype[ft] that returns a matching
      -- root_dir.
      local config = configs[server_name]
      -- Autcommands supply the file in relative (to cwd) fashion, but
      -- vim.fs.find (used in many root_dir functions) doesn't appear to search
      -- upwards from the relative root. Instead of handling it downstream,
      -- absolutize here.
      local root_dir = config.root_dir(path_absolute(args.file))
      if root_dir ~= nil then
        vim.lsp.start({
          name = server_name,
          cmd = config.cmd,
          root_dir = root_dir,
          capabilities = capabilities,
          settings = config.settings,
        })
        return
      end
    end
    print("WARNING: the filetype", ft,
      "is claimed by at least one LSP server config, but none were executable or had a non-nil root_dir, available:",
      vim.inspect(servers))
  end,
})

-- Synchronously organise (Go) imports.
--
-- Taken from
-- https://github.com/neovim/nvim-lsp/issues/115#issuecomment-654427197.
--
-- Spurious note: there is an "official" recommendation in the golang/tools
-- repo: https://github.com/golang/tools/blob/master/gopls/doc/vim. It appears
-- to be based on the comments in that thread, and specifically upon a version I
-- submitted to my dotfiles (but did not mention in the comments), compare:
--
--  - 2020-06-10: https://github.com/aktau/dotfiles/commit/bd848ca8b9b7a3f116c9438875f6f4b37b035a4f#diff-86f5da41be84a0e774e1cc85d8c02440b0a92d3550517ed3331e795b74c43c88
--  - 2021-02-23: https://go-review.googlesource.com/c/tools/+/294529
--
-- Later another fix was made, which also came from the github thread: following
-- the LSP spec and using "only" in the context to limit the LSP to organizing
-- imports instead of executing all available actions:
-- https://github.com/golang/tools/commit/6e9046bfcd34178dc116189817430a2ad1ee7b43.
--
-- A later comment by alexaandru@ made another robustness improvement: avoiding
-- the hardcoded "1" indexing. I combined this with a look at more recent
-- versions (0.6.0-git) of the Neovim LSP implementation to arrive at the
-- current version.
local function doCodeAction(name, offset_encoding)
  local params = vim.lsp.util.make_range_params()
  params.context = { only = { name } }

  local response = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
  for _, r in pairs(response or {}) do
    for _, action in pairs(r.result or {}) do
      -- textDocument/codeAction can return either Command[] or CodeAction[]. If
      -- it is a CodeAction, it can have either an edit, a command or both.
      -- Edits should be executed first.
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, offset_encoding)
      end
      if action.command then
        -- If the response was a Command[], then the inner "command' is a
        -- string, if the response was a CodeAction, then the inner command is a
        -- Command.
        local command = type(action.command) == "table" and action.command or action
        vim.lsp.buf.execute_command(command)
      end
    end
  end
end

-- Setup keybindings once an LSP client is attached.
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_augroup,
  callback = function(args)
    local bufnr = args.buf

    -- Integrate with builtin functionality.
    --
    -- In case of `omnifunc`, we also use a special completion plugin to trigger
    -- automatically, but it's nice to have a fallback to determin whether the
    -- plugin or the LSP is failing to trigger/complete.
    --
    -- In case of `tagfunc`, we also create our own `gd` mapping (see below) which
    -- does something similar. See https://github.com/neovim/neovim/issues/15309
    -- for a discussion. E.g., perform <c-w><c-]> to go to a definition in a new
    -- split.
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc" -- <C-x><C-o> in insert mode.
    vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr"
    vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"

    -- (Potentially) override some keybindings to use LSP functionality.
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local opts = { silent = true, buffer = bufnr }
    if client.server_capabilities.hoverProvider then
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    end
    -- Disable semantic highlighting. It has the Christmas tree effect [1] and
    -- there's some bug triggered by an internal LSP I haven't yet tracked down
    -- [2].
    --
    -- [1]: https://www.reddit.com/r/neovim/comments/zkvk18/colorscheme_modifications_to_reduce_christmas/
    -- [2]: https://github.com/neovim/neovim/issues/21387
    client.server_capabilities.semanticTokensProvider = nil
    vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "g0", vim.lsp.buf.document_symbol, opts)
    vim.keymap.set("n", "gW", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "ga", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<Leader>cl", vim.lsp.codelens.refresh, opts) -- Show available codelenses.
    vim.keymap.set("n", "<Leader>cL", vim.lsp.codelens.clear, opts)
    vim.keymap.set("n", "<Leader>cr", vim.lsp.codelens.run, opts)     -- Show the data in the lens (on the selected line, which may be at the top of the buffer for whole-file lenses).
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev({ float = false }) end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next({ float = false }) end, opts)

    local lsp_buffer_augroup = vim.api.nvim_create_augroup("lsp-buffer", {})
    local function aucmd(event, callback)
      vim.api.nvim_create_autocmd(event, { group = lsp_buffer_augroup, buffer = bufnr, callback = callback })
    end

    -- Enable format-on-save when available (see :help lsp-config). A
    -- discussion on how to do this with nvim-lsp:
    -- https://github.com/neovim/nvim-lsp/issues/115.
    --
    -- TODO: When gopls implements willSaveWaitUntil
    --       (https://github.com/golang/go/issues/57281), remove this.
    if client.server_capabilities.documentFormattingProvider then
      -- With gopls, textDocument/formatting only runs gofmt. If we also want
      -- goimports a specific code action. See
      -- https://github.com/Microsoft/language-server-protocol/issues/726.
      local ft = vim.bo[bufnr].filetype
      if ft == "go" then
        aucmd("BufWritePre", function() doCodeAction("source.organizeImports", client.offset_encoding) end)
      elseif ft == "python" then
        aucmd("BufWritePre", function() doCodeAction("quickfix.tidyImports", client.offset_encoding) end)
      end

      aucmd("BufWritePre", function() vim.lsp.buf.format({ timeout_ms = 1000 }) end)
    end

    if client.server_capabilities.documentHighlightProvider then
      aucmd("CursorHold", function() vim.lsp.buf.document_highlight() end)
      aucmd("CursorMoved", function() vim.lsp.util.buf_clear_references() end)
    end

    -- Draw a popup window showing all diagnostics.
    aucmd("CursorHold", function() vim.diagnostic.open_float() end)
  end,
})
