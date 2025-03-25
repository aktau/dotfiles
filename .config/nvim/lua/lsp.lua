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
  virtual_lines = false,    -- Apply virtual text in a shadow line.
  virtual_text = true,      -- Apply virtual text to line endings.
  float = {
    border = "single",
    header = false,
    scope = "line",
    source = "always",
    focusable = false, -- Don't mess with my normal window movements.
  }
})

--- @param name string
--- @param config vim.lsp.Config
local function configure(name, config)
  vim.lsp.config[name] = config
  vim.lsp.enable(name)
end

-- Turns a root finder that takes a file into a vim.lsp.Config.root_dir
-- function. If the root finder returns nil, the LSP is not started.
--
--- @param find fun(string): string?
--- @return fun(bufnr: integer, cb:fun(root_dir?:string))
local function make_root_fn(find)
  return function(bufnr, cb)
    local root = find(vim.api.nvim_buf_get_name(bufnr))
    if root then
      cb(root)
    end
  end
end

configure("clangd", {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_dir = make_root_fn(function(fname)
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
  end),
})

configure("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gotmpl" },
  root_dir = make_root_fn(function(fname)
    return vim.fs.root(fname, {
      "go.work",
    }) or vim.fs.root(fname, {
      ".git",
    }) or vim.fs.root(fname, {
      "go.mod",
    })
  end),
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
})

configure("efm", {
  cmd = { "efm-langserver" },
  filetypes = { "bash", "sh", "zsh" },
  -- Normally root_dir is set to util.root_pattern(".git"). But this means
  -- shellcheck is not enabled for any shell file not in a git repository,
  -- which is not desirable. `root_dir` is required, it servers as an LSP
  -- deduplication point. We only want one EFM so just set it to /.
  root_dir = "/",
})

configure("luals", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_dir = make_root_fn(function(fname)
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
  end),
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
})

local lsp_augroup = vim.api.nvim_create_augroup("lsp", { clear = true })

-- Make this global, to avoid looking it up every LspAttach (and we'd need to
-- avoid clearing with  clear = false} (clearing is the default).
local lsp_buffer_augroup = vim.api.nvim_create_augroup("lsp-buffer", {})

-- Setup keybindings once an LSP client is attached.
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_augroup,
  callback = function(args)
    local bufnr = args.buf
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

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


    -- Some language servers support various languages, and report the union of
    -- their capabilities as server_capabilities. Neovim (as of 2024-11-18)
    -- considers a static capability to supersede a dynamic one.
    local ft = vim.bo[bufnr].filetype
    local common_capability_override = {
      ["textDocument/documentHighlight"] = false,
      ["textDocument/inlayHint"] = false,
    }
    local capability_filetype_override = {
      markdown = common_capability_override,
    }

    local function supports(method)
      local ft_override = capability_filetype_override[ft]
      if ft_override ~= nil and ft_override[method] ~= nil then
        return ft_override[method]
      end
      return client:supports_method(method, bufnr)
    end

    -- Based on
    -- https://gist.github.com/MariaSolOs/2e44a86f569323c478e5a078d0cf98cc.
    if supports("textDocument/completion") then
      map("i", "<C-Space>", vim.lsp.completion.get, "Trigger autocompletion.")
      map("i", "<cr>", function() return (tonumber(vim.fn.pumvisible()) ~= 0) and '<C-y>' or '<cr>' end,
        { expr = true, desc = "Accept completion." })
      vim.lsp.completion.enable(true, args.data.client_id, bufnr, { autotrigger = true })
    end

    local function aucmd(event, callback)
      vim.api.nvim_create_autocmd(event, { group = lsp_buffer_augroup, buffer = bufnr, callback = callback })
    end

    -- Enable format-on-save when available (see :help lsp-config). A
    -- discussion on how to do this with nvim-lsp:
    -- https://github.com/neovim/nvim-lsp/issues/115.
    if supports("textDocument/formatting") then
      -- With gopls, textDocument/formatting only runs gofmt. If we also want
      -- goimports a specific code action. See
      -- https://github.com/Microsoft/language-server-protocol/issues/726.
      --
      -- TODO(aktau): Detect the presence of source.organizeImports (not just
      --              advertised, but actually working) on first save.
      if ft == "go" or ft == "python" then
        local options = { context = { only = { "source.organizeImports" } }, apply = true }
        -- TODO(aktau): Make synchronous if/when
        --              https://github.com/neovim/neovim/issues/31206 is fixed.
        --              Otherwise use a workaround like
        --              https://github.com/neovim/nvim-lspconfig/issues/115
        aucmd("BufWritePre", function() vim.lsp.buf.code_action(options) end)
      end

      -- Neovim supports willSaveWaitUntil since
      -- https://github.com/neovim/neovim/pull/21315. If so, it will
      -- automatically request pre-save edits. Most language servers will
      -- include formatting in this.
      if not supports("textDocument/willSaveWaitUntil") then
        aucmd("BufWritePre", function() vim.lsp.buf.format({ bufnr = bufnr, id = client.id, timeout_ms = 1000 }) end)
      end
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

    if supports("textDocument/inlayHint") and (vim.fn.has("nvim-0.10") == 1) then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      map("n", "<Leader>th", function()
        local enable = not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
        print(("%sing inlay hints"):format(enable and "enabl" or "disabl"))
        vim.lsp.inlay_hint.enable(enable, { bufnr = bufnr })
      end, "[T]oggle Inlay [H]ints")
    end

    -- Draw a popup window showing diagnostics for the given line.
    aucmd("CursorHold", function() vim.diagnostic.open_float() end)
  end,
})
