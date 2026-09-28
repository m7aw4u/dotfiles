-- Markdown-specific settings, applied automatically to markdown buffers only.
-- See `:help ftplugin`. Neovim's own runtime ftplugin/markdown.vim runs first
-- (it sets `formatoptions`, 4-space list indent, and `[[`/`]]` heading jumps) --
-- this file only adds what that doesn't already cover.

-- Conceal markup (**bold**, [text](url), `code`, ...) using the markdown_inline
-- treesitter query's built-in conceal rules -- but reveal it on whichever line
-- the cursor is on, so it stays editable. No plugin: this is treesitter +
-- Vim's native 'conceallevel'/'concealcursor'. See `:help conceallevel`
vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = ''

-- Wrap at word boundaries and hard-wrap prose at 80 columns as you type.
-- The `t` flag that makes this happen is already set by the runtime ftplugin;
-- it just needs a textwidth to wrap at. Reflow existing text with `gq` (see
-- `:help gq`), e.g. `gqip` to reflow the current paragraph.
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.textwidth = 80

-- Spellcheck prose, but don't flag Japanese/CJK text as misspelled English.
-- `]s`/`[s` jump between misspelled words, `z=` suggests a fix, `zg` adds a
-- word to the dictionary. See `:help spell`
vim.opt_local.spell = true
vim.opt_local.spelllang = 'en,cjk'

-- Fold by heading/section, code block, and list, using nvim-treesitter's
-- bundled markdown/folds.scm query via Neovim's native fold-by-treesitter
-- support. See `:help vim.treesitter.foldexpr()`
vim.opt_local.foldmethod = 'expr'
vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt_local.foldlevel = 99 -- start with everything open; `za` to toggle a fold

-- Toggle `- [ ]` <-> `- [x]` on the current line
vim.keymap.set('n', '<leader>x', function()
  local line = vim.api.nvim_get_current_line()
  if line:find '%[ %]' then
    vim.api.nvim_set_current_line((line:gsub('%[ %]', '[x]', 1)))
  elseif line:find '%[[xX]%]' then
    vim.api.nvim_set_current_line((line:gsub('%[[xX]%]', '[ ]', 1)))
  end
end, { buffer = true, desc = 'Toggle checkbox' })

-- Continue the list/checkbox marker onto the next line on <CR>, like most note
-- apps do. Pressing <CR> on an empty item (just the marker, nothing typed
-- after it) drops the marker and exits the list instead of repeating it
-- forever. No plugin -- Neovim's own formatoptions doesn't cover <CR>
-- (only `gq` reflow), so this fills that one gap with a buffer-local
-- insert-mode expr-mapping. See `:help :map-expression`
vim.keymap.set('i', '<CR>', function()
  local function keys(s)
    return vim.api.nvim_replace_termcodes(s, true, false, true)
  end
  -- NOTE: expr-mappings run with the buffer locked -- they can only compute
  -- and return a key sequence, not call nvim_set_current_line() etc. directly
  -- (Neovim raises E565 if you try). So "drop the marker" is done by
  -- returning <Esc>S (clear the line, re-enter insert), not an API call.
  local line = vim.api.nvim_get_current_line()

  local after_checkbox = line:match '^%s*[-*+] %[[ xX]%] ()'
  local after_bullet = line:match '^%s*[-*+] ()'
  local indent, num, sep = line:match '^(%s*)(%d+)([.)] )'

  if after_checkbox then
    if line:sub(after_checkbox) == '' then
      return keys '<Esc>S'
    end
    return keys('<CR>' .. line:sub(1, after_checkbox - 1):gsub('%[[ xX]%]', '[ ]'))
  elseif after_bullet then
    if line:sub(after_bullet) == '' then
      return keys '<Esc>S'
    end
    return keys('<CR>' .. line:sub(1, after_bullet - 1))
  elseif indent then
    local prefix_len = #indent + #num + #sep
    if line:sub(prefix_len + 1) == '' then
      return keys '<Esc>S'
    end
    return keys('<CR>' .. indent .. tostring(tonumber(num) + 1) .. sep)
  end

  return keys '<CR>'
end, { buffer = true, expr = true, desc = 'Continue list/checkbox, or exit an empty one' })

-- Already native, no config needed, worth knowing for note-taking:
--   gx    open the URL/file under the cursor (netrw)
--   gf    open the file path under the cursor
--   [[ ]] jump to previous/next heading
