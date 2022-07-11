-- for debugging
--  :lua require('vim.lsp.log').set_level("debug")
--  :lua print(vim.inspect(vim.lsp.buf_get_clients()))
--  :lua print(vim.lsp.get_log_path())
--  :lua print(vim.inspect(vim.tbl_keys(vim.lsp.callbacks)))

-- Configure diagnostics globally, which also applies to LSP diagnostics via
-- vim.lsp.diagnostic.on_publish_diagnostics.
vim.diagnostic.config({
  severity_sort = true,
  signs = true,              -- Apply signs for diagnostics.
  underline = true,          -- Apply underlines to diagnostics.
  update_in_insert = false,  -- Do not update diagnostics while still inserting.
  virtual_text = true,       -- Apply virtual text to line endings.
  float = {
    border = "single",
    header = false,
    scope = "line",
    source = "always",
  }
})

-- Find the nearest parent directory (of `start`) that contains a file in
-- `basenames`.
local function find_first_parent(start, basenames)
  return vim.fs.dirname(vim.fs.find(basenames, { path = vim.fs.dirname(fname), upward = true })[1])
end

local configs = {
  ["clangd"] = {
    cmd = { "clangd" },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    root_dir = function(fname)
      local wd = vim.fs.dirname(fname)
      return find_first_parent(wd, {
        ".clangd",
        ".clang-tidy",
        ".clang-format",
        "compile_commands.json",
        "compile_flags.txt",
        "configure.ac", -- AutoTools
      }) or find_first_parent(wd, {
        ".git",
      })
    end,
  },
  ["gopls"] = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gotmpl" },
    root_dir = function(fname)
      local wd = vim.fs.dirname(fname)
      return find_first_parent(wd, {
        "go.work",
      }) or find_first_parent(wd, {
        "go.mod",
        ".git",
      })
    end,
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
}

-- Lookup table of LSP servers by filetype.
local servers_by_filetype = {}

-- Will make `server_name` the _first_ server started for every item in
-- `filetypes`.
local function register_server_for_filetypes(server_name, filetypes)
  -- Prepend `item` to the list (`tbl`), or create the list.
  local function tbl_prepend(tbl, item)
    if tbl == nil then
      return {item}
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
        fname = vim.loop.fs_realpath(fname)
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

local capabilities = {}

local has_cmp, cmp = pcall(require, 'cmp')
local has_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if has_cmp and has_cmp_nvim_lsp then
  capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())

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

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
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
      local root_dir = config.root_dir(args.file)
      if root_dir ~= nil then
        vim.lsp.start({
          name = server_name,
          cmd = config.cmd,
          root_dir = root_dir,
          capabilities = capabilities,
        })
        return
      end
    end
    print("WARNING: the filetype", ft, "is claimed by at least one LSP server config, but none were executable or had a non-nil root_dir, available:", vim.inspect(servers))
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
local function goimports()
  local params = vim.lsp.util.make_range_params()
  params.context = { only = { "source.organizeImports" } }

  local response = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
  for _, r in pairs(response or {}) do
    for _, action in pairs(r.result or {}) do
      -- textDocument/codeAction can return either Command[] or CodeAction[]. If
      -- it is a CodeAction, it can have either an edit, a command or both.
      -- Edits should be executed first.
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit)
      end
      if action.command then
        local command = type(action.command) == "table" and action.command or action
        vim.lsp.buf.execute_command(action.command)
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
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"-- <C-x><C-o> in insert mode.
    vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr"
    vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"

    -- (Potentially) override some keybindings to use LSP functionality.
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local opts = { silent = true, buffer = bufnr }
    if client.server_capabilities.hoverProvider then
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    end
    vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "g0", vim.lsp.buf.document_symbol, opts)
    vim.keymap.set("n", "gW", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "ga", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev({float = false}) end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next({float = false}) end, opts)

    local lsp_buffer_augroup = vim.api.nvim_create_augroup("lsp-buffer", {})
    local function aucmd(event, callback)
      vim.api.nvim_create_autocmd(event, { group = lsp_buffer_augroup, buffer = bufnr, callback = callback })
    end

    -- Enable format-on-save when available (see :help lsp-config). A
    -- discussion on how to do this with nvim-lsp:
    -- https://github.com/neovim/nvim-lsp/issues/115.
    --
    -- TODO: When gopls implements willSaveWaitUntil (no issue yet), use it
    --       instead as it saves a roundtrip:
    --       https://github.com/Microsoft/language-server-protocol/issues/726.
    if client.server_capabilities.documentFormattingProvider then
      -- With gopls, textDocument/formatting only runs gofmt. If we also want
      -- goimports a specific code action. See
      -- https://github.com/Microsoft/language-server-protocol/issues/726.
      if vim.bo[bufnr].filetype == "go" then
        aucmd("BufWritePre", function() goimports() end)
      end
      aucmd("BufWritePre", function() vim.lsp.buf.format({timeout_ms=1000}) end)
    end

    if client.server_capabilities.documentHighlightProvider then
      aucmd("CursorHold", function() vim.lsp.buf.document_highlight() end)
      aucmd("CursorMoved", function() vim.lsp.util.buf_clear_references() end)
    end

    -- Draw a popup window showing all diagnostics.
    aucmd("CursorHold", function() vim.diagnostic.open_float() end)
  end,
})
