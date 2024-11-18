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
    focusable = false, -- Don't mess with my normal window movements.
  }
})

local configs = {
  ["clangd"] = {
    cmd = { "clangd" },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    root_dir = function(fname)
      return vim.fs.root(fname, {
        ".clangd",
        ".clang-tidy",
        ".clang-format",
        "compile_commands.json",
        "compile_flags.txt",
        "configure.ac", -- AutoTools
      }) or vim.fs.root(fname, {
        ".git",
      })
    end,
  },
  ["gopls"] = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gotmpl" },
    root_dir = function(fname)
      return vim.fs.root(fname, {
        "go.work",
      }) or vim.fs.root(fname, {
        ".git",
      }) or vim.fs.root(fname, {
        "go.mod",
      })
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
  ["luals"] = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_dir = function(fname)
      return vim.fs.root(fname, {
        ".luarc.json",
        ".luarc.jsonc",
        ".luacheckrc",
        ".stylua.toml",
        "stylua.toml",
        "selene.toml",
        "selene.yml",
      }) or vim.fs.root(fname, {
        ".git",
      }) or vim.fs.root(fname, {
        "lua",
      }) or os.getenv("HOME")
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

-- Add utf-8 in the default capability set. Neovim defaults to only utf-16 since
-- https://github.com/neovim/neovim/commit/ca26ec3438 because it is unable to
-- deal with different encodings if there are multiple clients for a buffer. But
-- we use only one client per buffer (clangd supports utf-8, for example).
capabilities.general.positionEncodings = {
  "utf-8",
  "utf-16",
}

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
      local root_dir = config.root_dir(vim.api.nvim_buf_get_name(0))
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

-- Make this global, to avoid looking it up every LspAttach (and we'd need to
-- avoid clearing with  clear = false} (clearing is the default).
local lsp_buffer_augroup = vim.api.nvim_create_augroup("lsp-buffer", {})

-- Setup keybindings once an LSP client is attached.
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_augroup,
  callback = function(args)
    local bufnr = args.buf

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    -- Disable semantic highlighting. It has the Christmas tree effect [1] and
    -- there's some bug triggered by an internal LSP I haven't yet tracked down
    -- [2].
    --
    -- [1]: https://www.reddit.com/r/neovim/comments/zkvk18/colorscheme_modifications_to_reduce_christmas/
    -- [2]: https://github.com/neovim/neovim/issues/21387
    client.server_capabilities.semanticTokensProvider = nil

    -- (Potentially) override some keybindings to use LSP functionality.
    local function map(mode, key, fn, opts)
      opts = vim.tbl_extend("force", { silent = true, buffer = bufnr },
        type(opts) == 'string' and { desc = opts } or opts)
      vim.keymap.set(mode, key, fn, opts)
    end
    -- Defaults (:h lsp-defaults):
    --  - grn (rename symbol)
    --  - gra (apply action)
    --  - grr (references)
    --  - gri (implementation)
    --  - gO (symbols)
    --  - K (hover info)
    --  - ]d (go to diagnostics)
    --  - i_CTRL-S (display signature information in insert mode)
    map("n", "gd", vim.lsp.buf.definition, "Jumps to the definition of the symbol under the cursor.")
    map("n", "gt", vim.lsp.buf.type_definition, "Jumps to the definition of the type of the symbol under the cursor.")
    -- Override the default gra mapping because it doesn't set the { apply =
    -- true } option. The default mapping is global, so this buffer-local one
    -- takes precedence.
    map({ "n", "x" }, "gra", function() vim.lsp.buf.code_action({ apply = true }) end,
      "Selects a code action available at the current cursor position.")

    -- Lenses
    map("n", "<Leader>cl", vim.lsp.codelens.refresh, "Show available codelenses.")
    map("n", "<Leader>cL", vim.lsp.codelens.clear, "Clear the lenses.")
    map("n", "<Leader>cr", vim.lsp.codelens.run,
      "Show the data in the lens on the selected line (may be at the top of the buffer for whole-file lenses).")

    -- Based on
    -- https://gist.github.com/MariaSolOs/2e44a86f569323c478e5a078d0cf98cc.
    if client.supports_method("textDocument/completion") then
      map("i", "<C-Space>", vim.lsp.completion.trigger, "Trigger autocompletion.")
      map("i", "<cr>", function() return (tonumber(vim.fn.pumvisible()) ~= 0) and '<C-y>' or '<cr>' end,
        { expr = true, desc = "Accept completion." })
      vim.lsp.completion.enable(true, args.data.client_id, bufnr, { autotrigger = true })
    end

    local function aucmd(event, callback)
      vim.api.nvim_create_autocmd(event, { group = lsp_buffer_augroup, buffer = bufnr, callback = callback })
    end

    -- Some language servers support various languages, and report the union of
    -- their capabilities as server_capabilities. Neovim (as of 2024-11-18)
    -- considers a static capability to supersede a dynamic one.
    local ft = vim.bo[bufnr].filetype
    local capability_filetype_override = {
      markdown = {
        ["textDocument/documentHighlight"] = false,
        ["textDocument/inlayHint"] = false,
      },
    }

    local function supports(method, opts)
      local ft_override = capability_filetype_override[ft]
      if ft_override ~= nil and ft_override[method] ~= nil then
        return ft_override[method]
      end

      return client.supports_method(method, opts)
    end

    -- Enable format-on-save when available (see :help lsp-config). A
    -- discussion on how to do this with nvim-lsp:
    -- https://github.com/neovim/nvim-lsp/issues/115.
    --
    -- TODO: When gopls implements willSaveWaitUntil
    --       (https://github.com/golang/go/issues/57281), remove this.
    if supports("textDocument/formatting") then
      -- With gopls, textDocument/formatting only runs gofmt. If we also want
      -- goimports a specific code action. See
      -- https://github.com/Microsoft/language-server-protocol/issues/726.
      if vim.bo[bufnr].filetype == "go" then
        local options = { context = { only = { "source.organizeImports" } }, apply = true }
        aucmd("BufWritePre", function() vim.lsp.buf.code_action(options) end)
      end

      aucmd("BufWritePre", function() vim.lsp.buf.format({ timeout_ms = 1000 }) end)
    end

    if supports("textDocument/documentHighlight") then
      -- may not need this if your colorscheme supports these highlight groups
      -- already. Support for mhartingon/oceanic-next (my current scheme) is
      -- requested in https://github.com/mhartington/oceanic-next/issues/120.
      -- Alternatively (more understated):
      if not vim.fn.hlexists("LspReferenceRead") then
        vim.api.nvim_set_hl(0, "LspReferenceRead", { link = "Visual" })
        vim.api.nvim_set_hl(0, "LspReferenceText", { link = "Visual" })
        vim.api.nvim_set_hl(0, "LspReferenceWrite", { link = "Visual" })
      end

      aucmd("CursorHold", function() vim.lsp.buf.document_highlight() end)
      aucmd("CursorMoved", function() vim.lsp.buf.clear_references() end)
    end

    -- Draw a popup window showing diagnostics for the given line.
    aucmd("CursorHold", function() vim.diagnostic.open_float() end)
  end,
})
