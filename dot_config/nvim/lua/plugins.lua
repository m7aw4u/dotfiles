-- [[ Configure and install plugins ]]
--
-- To check the current status of your plugins, run `:Lazy`. Press `?` in that
-- window for help, `:q` to close it. To update plugins, run `:Lazy update`.
--
-- Every plugin below was chosen because it does something Neovim's own
-- builtin features can't reasonably replace. See ../README.md for the full
-- reasoning behind each one and what was deliberately left out.
require('lazy').setup({
  -- Detect tabstop/shiftwidth automatically from the file being edited
  'tpope/vim-sleuth',

  { -- Fuzzy finder: files, live grep, help, diagnostics, buffers
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup {}

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Find existing buffers' })
    end,
  },

  { -- Git status in the sign column + hunk stage/reset/preview/blame
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map('n', ']c', gitsigns.next_hunk, 'Next git hunk')
        map('n', '[c', gitsigns.prev_hunk, 'Previous git hunk')
        map('n', '<leader>hs', gitsigns.stage_hunk, 'Git [s]tage hunk')
        map('n', '<leader>hr', gitsigns.reset_hunk, 'Git [r]eset hunk')
        map('n', '<leader>hp', gitsigns.preview_hunk, 'Git [p]review hunk')
        map('n', '<leader>hb', gitsigns.blame_line, 'Git [b]lame line')
      end,
    },
  },

  { -- Format on save via external formatters LSP servers don't cover
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      format_on_save = { timeout_ms = 500, lsp_format = 'fallback' },
      formatters_by_ft = {
        lua = { 'stylua' },
        yaml = { 'yamlfmt' },
        toml = { 'taplo' },
        sh = { 'shfmt' },
      },
    },
  },

  { -- Syntax highlighting via real parsers, not regex
    -- NOTE: pinned to the classic `master` branch API (configs.setup), not the
    -- rewritten `main` branch -- that one needs the standalone `tree-sitter` CLI
    -- installed to compile parsers, which this machine doesn't have. `master`
    -- compiles parsers with just a C compiler (`cc`), so it needs nothing extra.
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'lua',
        'vim',
        'vimdoc',
        'markdown',
        'markdown_inline',
        'yaml',
        'json',
        'toml',
        'bash',
        'diff',
        'query',
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  { -- Installs LSP servers and wires them up via vim.lsp.enable()
    'mason-org/mason-lspconfig.nvim',
    opts = {
      ensure_installed = { 'lua_ls', 'jsonls', 'yamlls', 'marksman', 'bashls', 'taplo' },
    },
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'neovim/nvim-lspconfig',
    },
  },
}, {
  ui = {
    -- No Nerd Font: use lazy.nvim's plain-text icon fallback
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- Per-server LSP settings + native completion wiring (see lua/lsp.lua)
require 'lsp'

-- vim: ts=2 sts=2 sw=2 et
