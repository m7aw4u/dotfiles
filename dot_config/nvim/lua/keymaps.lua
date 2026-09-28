-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- NOTE: Neovim ships default LSP keymaps you don't need to redefine here:
--   grn (rename), gra (code action), grr (references), gri (implementation),
--   grt (type definition), gO (document symbols), K (hover),
--   ]d / [d (next/prev diagnostic), <C-w>d (diagnostic float)
--  See `:help lsp-defaults`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- `gd` is a plain-text motion by default (not LSP-aware) -- point it at the LSP
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover than <C-\><C-n>.
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- `autoread` (on by default) only takes effect when Neovim actually checks
-- the file's timestamp -- it does not watch the filesystem. Without this,
-- a file edited by another process (another editor, a script, Claude Code
-- running in a separate terminal/tmux pane, ...) will look unchanged here
-- until something forces a check. This runs that check whenever you come
-- back to Neovim or pause typing. See `:help autoread` and `:help checktime`
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
  desc = 'Check for file changes made outside Neovim',
  group = vim.api.nvim_create_augroup('checktime', { clear = true }),
  command = 'checktime',
})

-- vim: ts=2 sts=2 sw=2 et
