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

-- Synchronously organise (Go) imports. Taken from
-- https://github.com/neovim/nvim-lsp/issues/115#issuecomment-654427197.
function go_organize_imports_sync(timeout_ms)
  local context = { source = { organizeImports = true } }
  vim.validate { context = { context, 't', true } }
  local params = vim.lsp.util.make_range_params()
  params.context = context

  -- See the implementation of the textDocument/codeAction callback
  -- (lua/vim/lsp/callbacks.lua) for how to do this properly.
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
  if not result then return end
  local actions = result[1].result
  if not actions then return end
  local action = actions[1]

  -- textDocument/codeAction can return either Command[] or CodeAction[]. If it
  -- is a CodeAction, it can have either an edit, a command or both. Edits
  -- should be executed first.
  if action.edit or type(action.command) == "table" then
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit)
    end
    if type(action.command) == "table" then
      vim.lsp.buf.execute_command(action.command)
    end
  else
    vim.lsp.buf.execute_command(action)
  end
end

local function on_attach(client, bufnr)
  -- Source omnicompletion from LSP.
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

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
  vim.api.nvim_buf_set_keymap(bufnr, "n", "ga", '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)

  local has_completion, completion = pcall(require, 'completion')
  if has_completion then
    completion.on_attach()
  end

  augroup(
    "LSP",
    function()
      -- Enable format-on-save when available (see :help lsp-config). A discussion
      -- on how to do this with nvim-lsp:
      -- https://github.com/neovim/nvim-lsp/issues/115.
      --
      -- TODO: When gopls implements willSaveWaitUntil (no issue yet), use it
      --       instead as it saves a roundtrip:
      --       https://github.com/Microsoft/language-server-protocol/issues/726.
      if client.resolved_capabilities.document_formatting then
        -- With gopls, textDocument/formatting only runs gofmt. If we also want
        -- goimports, we need to run "all" code actions. See
        -- https://github.com/Microsoft/language-server-protocol/issues/726.
        if vim.api.nvim_buf_get_option(bufnr, "filetype") == "go" then
          vim.api.nvim_command("autocmd BufWritePre <buffer> lua go_organize_imports_sync(1000)")
        end
        vim.api.nvim_command("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)")
      end

      if client.resolved_capabilities.document_highlight then
        vim.api.nvim_command("autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()")
        vim.api.nvim_command("autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()")
        vim.api.nvim_command("autocmd CursorMoved <buffer> lua vim.lsp.util.buf_clear_references()")
      end


      -- `show_line_diagnostics` draws a nice popup window. I like it when this
      -- appears when I hover over a line with a diagnostic. This hack
      -- accomplishes that.
      --
      -- Source: https://github.com/nvim-lua/diagnostic-nvim/issues/29
      vim.api.nvim_command('autocmd CursorHold <buffer> lua vim.lsp.diagnostic.show_line_diagnostics({show_header=false})')
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
        runtime = { version = "LuaJIT" }
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

for lsp, config in pairs(servers) do
  lspconfig[lsp].setup(vim.tbl_extend(
    'force',
    { on_attach = on_attach },
    config
  ))
end


-- Configure nvim-lsp with handlers. More specifically: diagnostics.
-- https://github.com/nvim-lua/diagnostic-nvim/issues/73
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {
    virtual_text = true,  -- Apply virtual text to line endings.
    underline = true,  -- Apply underlines to diagnostics.
    signs = true,  -- Apply signs for diagnostics.
    update_in_insert = false,  -- Do not update diagnostics while still inserting.
  }
)
