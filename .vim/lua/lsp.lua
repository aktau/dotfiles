-- for debugging
-- :lua require('vim.lsp.log').set_level("debug")
-- :lua print(vim.inspect(vim.lsp.buf_get_clients()))
-- :lua print(vim.lsp.get_log_path())
-- :lua print(vim.inspect(vim.tbl_keys(vim.lsp.callbacks)))

-- This setup was inspired by:
--
--  * https://gitlab.com/SanchayanMaity/dotfiles/-/blob/master/nvim/.config/nvim/lua/lsp.lua
--  * https://github.com/ahmedelgabri/dotfiles/blob/master/roles/vim/files/.vim/lua/lsp.lua
local has_lspconfig, lspconfig = pcall(require, 'lspconfig')
if not has_lspconfig then
  print("install the 'github.com/neovim/nvim-lspconfig' plugin to get LSP support")
  return
end

local has_cmp, cmp = pcall(require, 'cmp')
local has_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if has_cmp and has_cmp_nvim_lsp then
  cmp.setup({
    snippet = {
      -- cmp-nvim requires a snippet engine.
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end,
    },
    mapping = {
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'buffer' },
    }
  })
end

-- TODO: extract to a utility library when I get more lua things.
--
-- Stolen from
-- https://github.com/ahmedelgabri/dotfiles/blob/94373b988275b415e24ef7757349fb02b809c3df/roles/vim/files/.vim/lua/_/utils.lua.
local function augroup(group, fn)
  vim.api.nvim_command("augroup " .. group)
  vim.api.nvim_command("autocmd!")
  fn()
  vim.api.nvim_command("augroup END")
end

-- For debugging:
--
-- vim.lsp.set_log_level("trace") -- "trace", "debug", "info", "warn", "error"
-- print('LSP logging to:', vim.lsp.get_log_path())

-- Functionality for a peek/preview pane.
--
-- Taken from
-- https://www.reddit.com/r/neovim/comments/gyb077/nvimlsp_peek_defination_javascript_ttserver
--
-- Remove this if it ever gets submitted.
local function preview_location(location, context, before_context)
  -- location may be LocationLink or Location (more useful for the former)
  context = context or 10
  before_context = before_context or 5
  local uri = location.targetUri or location.uri
  if uri == nil then
    return
  end
  local bufnr = vim.uri_to_bufnr(uri)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
  end
  local range = location.targetRange or location.range
  local contents =
    vim.api.nvim_buf_get_lines(bufnr, range.start.line - before_context, range["end"].line + 1 + context, false)
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  return vim.lsp.util.open_floating_preview(contents, filetype)
end

local function preview_location_callback(_, method, result)
  local context = 10
  if result == nil or vim.tbl_isempty(result) then
    print("No location found: " .. method)
    return nil
  end
  if vim.tbl_islist(result) then
    floating_buf, floating_win = preview_location(result[1], context)
  else
    floating_buf, floating_win = preview_location(result, context)
  end
end

-- Global function that will be called from a keybinding.
function lsp_peek_definition()
  if vim.tbl_contains(vim.api.nvim_list_wins(), floating_win) then
    vim.api.nvim_set_current_win(floating_win)
  else
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(0, "textDocument/definition", params, preview_location_callback)
  end
end

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
--
-- Some LSPs (like pyright) instead perform this function as a command, see the
-- example in https://github.com/neovim/nvim-lspconfig/issues/1221.
function goimports(timeout_ms)
  local params = vim.lsp.util.make_range_params()
  params.context = { only = { "source.organizeImports" } }

  local response = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
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

local function on_attach(client, bufnr)
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
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc") -- <C-x><C-o> in insert mode.
  vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr")
  vim.api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")

  -- (Potentially) override some keybindings to use LSP functionality.
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<Leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "K",  "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "g0", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gW", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "pd", "<cmd>lua lsp_peek_definition()<CR>", opts)
  -- TODO: Try out github.com/RishabhRD/nvim-lsputils for more stylish code
  -- actions. Example: https://github.com/ahmedelgabri/dotfiles/commit/546dfc37cd9ef110664286eb50ece4713108a511.
  vim.api.nvim_buf_set_keymap(bufnr, "n", "ga", '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)

  augroup(
    "LSP",
    function()
      -- Enable format-on-save when available (see :help lsp-config). A
      -- discussion on how to do this with nvim-lsp:
      -- https://github.com/neovim/nvim-lsp/issues/115.
      --
      -- A discussion on how to do this better (more asynchronously) for slow
      -- LSPs:
      -- https://www.reddit.com/r/neovim/comments/jvisg5/lets_talk_formatting_again
      --
      -- TODO: When gopls implements willSaveWaitUntil (no issue yet), use it
      --       instead as it saves a roundtrip:
      --       https://github.com/Microsoft/language-server-protocol/issues/726.
      if client.resolved_capabilities.document_formatting then
        -- With gopls, textDocument/formatting only runs gofmt. If we also want
        -- goimports, we need to run "all" code actions. See
        -- https://github.com/Microsoft/language-server-protocol/issues/726.
        if vim.api.nvim_buf_get_option(bufnr, "filetype") == "go" then
          vim.api.nvim_command("autocmd BufWritePre <buffer> lua goimports(1000)")
        end
        vim.api.nvim_command("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)")
      end

      if client.resolved_capabilities.document_highlight then
        vim.api.nvim_command("autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()")
        vim.api.nvim_command("autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()")
        vim.api.nvim_command("autocmd CursorMoved <buffer> lua vim.lsp.util.buf_clear_references()")
      end

      -- Draw a popup window showing all diagnostic.
      --
      -- Source: https://github.com/nvim-lua/diagnostic-nvim/issues/29
      vim.api.nvim_command('autocmd CursorHold <buffer> lua vim.diagnostic.open_float(0, {show_header=false, scope="line", border="single", source="always"})')
    end
  )
end

local servers = {
  ['clangd'] = {},
  ['gopls'] = {},
  ['rust_analyzer'] = {},
  ['sumneko_lua'] = {
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
          path = vim.split(package.path, ';'),
        },
        diagnostics = {
          globals = { 'vim' },
        },
        workspace = {
          library = {
            [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
          }
        }
      }
    }
  },

  -- A generic langserver that can be used to pull regular linters into the LSP
  -- ecosystem (like shellcheck).
  ['efm'] = {
    -- TODO: Figure out how to avoid:
    --   efm doesn't implement a number of capabilities:
    --     Error executing vim.schedule lua callback: ...geer/neovim/share/nvim/runtime/lua/vim/lsp/callbacks.lua:259: RPC[Error] code_name = MethodNotFound, message = "method not supported: textDocument/documentHighlight"
    --     data = vim.NIL
    filetypes = { 'bash', 'sh', 'zsh' },
    -- Normally root_dir is set to util.root_pattern(".git"). But this means
    -- shellcheck is not enabled for any shell file not in a git repository,
    -- which is not desirable. `root_dir` is required, it servers as an LSP
    -- deduplication point. We only want one EFM so just set it to /.
    root_dir = function() return '/' end,
  },
}

-- Add custom LSP for certain environments. The tricky thing is to make it the
-- preferential LSP whenever it is applicable (correct filetype and root),
-- excluding other LSPs.

-- override_lsp_root returns the first matching root from
-- `g:aktau_override_lsp.roots` that `fname` is a child of, returns nil if none
-- match.
local override_lsp_root = function() return nil end
local override_lsp = vim.g.aktau_override_lsp
if override_lsp ~= nil then
  override_lsp_root = function(fname)
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
  end

  local configs = require('lspconfig/configs')
  configs[override_lsp.name] = {
    default_config = {
      cmd = override_lsp.cmd,
      filetypes = override_lsp.filetypes,
      -- Only run instances of the remote fs LSP for files that are actually on
      -- the remote fs.
      root_dir = override_lsp_root,
      settings = {},
    },
  }
  servers[override_lsp.name] = {}
end

do
  local defaults = {
    on_attach = on_attach,
  }

  if has_cmp and has_cmp_nvim_lsp then
    defaults.capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())
  end

  for lsp, config in pairs(servers) do
    -- The `override_lsp`, if set, inhibits all other LSPs that would activate
    -- for the same root.
    local overrides = {}
    if override_lsp ~= nil and lsp ~= override_lsp.name then
      -- Ensure the regular LSPs do not run in the overridden roots.
      overrides.on_new_config = function(config, root_dir)
        -- TODO: don't install the override if the filetypes don't match (so
        --       that efm-langserver can work in all scenarios).
        config.enabled = (override_lsp_root(root_dir) == nil)
      end
    end

    lspconfig[lsp].setup(vim.tbl_deep_extend(
      'force',
      defaults,
      config,
      overrides
    ))
  end
end

-- Configure nvim-lsp with handlers. More specifically: diagnostics.
-- https://github.com/nvim-lua/diagnostic-nvim/issues/73
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {
    severity_sort = true,
    signs = true,  -- Apply signs for diagnostics.
    underline = true,  -- Apply underlines to diagnostics.
    update_in_insert = false,  -- Do not update diagnostics while still inserting.
    virtual_text = true,  -- Apply virtual text to line endings.
  }
)
