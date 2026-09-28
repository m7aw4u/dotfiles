-- [[ LSP server configuration ]]
--
-- Servers are installed and enabled automatically by mason-lspconfig
-- (see the `mason-lspconfig.nvim` spec in lua/plugins.lua, `ensure_installed`).
-- This file only holds per-server setting overrides and the native-completion wiring.
--
-- See `:help vim.lsp.config()`, `:help lspconfig-all`, and for lua_ls settings:
-- https://luals.github.io/wiki/settings/

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      completion = { callSnippet = 'Replace' },
    },
  },
})

vim.lsp.config('yamlls', {
  settings = {
    yaml = { keyOrdering = false },
  },
})

-- [[ Native completion ]]
--
-- No completion plugin (nvim-cmp etc.) is used here. Neovim's own LSP completion
-- (`:help lsp-completion`) is enabled per-buffer when a server attaches.
-- `completeopt` is set in lua/options.lua. Once enabled: the popup appears as you
-- type (autotrigger), <C-n>/<C-p> to move, <C-y> to confirm -- all builtin ins-completion.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method 'textDocument/completion' then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end
  end,
})

-- vim: ts=2 sts=2 sw=2 et
