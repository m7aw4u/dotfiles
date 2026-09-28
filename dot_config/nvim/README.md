# Neovim設定

以前は [kickstart-modular.nvim](https://github.com/dam9000/kickstart-modular.nvim) を丸ごとコピーしただけの構成で、`coc.nvim` と `nvim-cmp` が二重に動くなど、一度も精査されずに20個近いプラグインが積み上がっていた。2026-09に、必要最小限の構成へゼロから作り直した。

## 採用方針

**Neovim標準機能で代替できるものはプラグインを使わない。プラグインを入れるのは、標準機能では実現困難なものだけ。** 新しいプラグインを足したくなったら、まず「これは本当に標準機能でできないか」を疑うこと。

- LSPはNeovim標準の `vim.lsp` + `nvim-lspconfig`（設定データ集）+ `mason.nvim`（サーバのインストーラ）だけで組む。`coc.nvim` のようなオールインワン系や `nvim-cmp` のような補完プラグインは使わない。
- 補完はNeovim組み込みの `vim.lsp.completion`（0.11+）を使う。`<C-y>`で確定、`<C-n>`/`<C-p>`で選択という標準の ins-completion 操作だけで完結する。
- キーマップもNeovim標準搭載分（`grn`/`gra`/`grr`/`gri`/`grt`/`gO`/`K`/`]d`/`[d` など、`:help lsp-defaults` 参照）は再定義しない。`lua/keymaps.lua` にあるのは、それで足りない分だけ。
- ファイルツリーはnetrw、カラースキームは組み込みの `habamax`。

## プラグイン一覧（8個 + lazy.nvim）

| プラグイン | 採用理由 |
|---|---|
| `neovim/nvim-lspconfig` | LSPサーバの既定設定データ |
| `mason-org/mason.nvim` | LSPサーバ/フォーマッタのインストール管理 |
| `mason-org/mason-lspconfig.nvim` | Masonのインストールと`vim.lsp.enable()`を繋ぐ |
| `nvim-treesitter/nvim-treesitter` | パーサベースのシンタックスハイライト（標準では代替不可） |
| `nvim-telescope/telescope.nvim` | ファジーファインダー。`:grep`+`:copen`のネイティブ経路も`grepprg`で使える |
| `lewis6991/gitsigns.nvim` | Git差分ガター・hunk操作 |
| `stevearc/conform.nvim` | `stylua`/`yamlfmt`/`taplo`/`shfmt`など、LSPでは整形できない言語の保存時フォーマット |
| `tpope/vim-sleuth` | ファイルごとのインデント自動検出 |

## 対象用途とLSPサーバ

設定ファイル・Markdown中心の編集（YAML/JSON/TOML/Lua/Bash/Markdown）を想定し、`mason-lspconfig` の `ensure_installed` を `lua_ls`, `jsonls`, `yamlls`, `marksman`, `bashls`, `taplo` に絞っている。Python/JS/TS/Goなどが必要になったら `lua/plugins.lua` の `ensure_installed` にサーバ名を足すだけでよい（`:help lspconfig-all` にサーバ一覧がある）。

## 初回セットアップ

`:Lazy sync` でプラグインが入った後、`:Mason` を開いて `stylua`/`yamlfmt`/`taplo`/`shfmt` が入っているか確認する（`ensure_installed`に無いのでLSPサーバのように自動では入らない。入れる場合は `:MasonInstall stylua yamlfmt taplo shfmt`)。

## Markdown編集（`ftplugin/markdown.lua`）

タスクメモをMarkdownで書く用途を想定し、Markdownバッファにだけ効く設定を`ftplugin/markdown.lua`に追加している（`:help ftplugin`。Neovimがファイルタイプ判定時に自動で読み込む、プラグイン不要のネイティブな仕組み）。

- `conceallevel=2` — treesitterの`markdown_inline`クエリが元々持っている conceal 定義を使って`**太字**`や`[リンク](url)`の記号を隠す。カーソル行だけは`concealcursor=''`で常に生表示にして編集可能に保つ
- 見出し・コードブロック・リスト単位でのfold — `vim.treesitter.foldexpr()`（Neovim 0.10+ネイティブ）が、treesitter-nvimに同梱の`markdown/folds.scm`クエリを使って計算する
- `textwidth=80` + Neovim標準の`markdown.vim`が既に設定している`formatoptions+=t`で、入力しながら自動折り返し。既存文章の再整形は`gq`（例: `gqip`で段落を再整形）
- `spell`（`en,cjk`でCJK文字は誤検出しない）。`]s`/`[s`で次/前の誤字へ、`z=`で修正候補、`zg`で辞書登録
- `<leader>x` でカーソル行の `- [ ]` / `- [x]` をトグル
- リスト/チェックボックス行で`<CR>` → 次の行にも同じマーカーを自動継続（番号リストは採番も+1）。中身が空のマーカー行で`<CR>`を押すとマーカーを消してリストを抜ける（Notion等と同じ挙動）。Neovim標準の`formatoptions`は`gq`の再整形にしか効かず`<CR>`時の継続は面倒を見ないので、そこだけ`<CR>`にexprマッピングを足して埋めている

**あえてMarkdown用フォーマッタ(prettier等)は`conform.nvim`に足していない。** npm等の追加ツール依存を増やすより、上記のネイティブな折り返し(`gq`/`textwidth`)で十分だと判断した。自動整形が欲しくなったら`lua/plugins.lua`の`conform.nvim`の`formatters_by_ft`に`markdown = { "prettier" }`等を足せばよい。

すでにネイティブで使える機能（設定不要）:
- `gx` — カーソル下のURL/ファイルを開く（netrw）
- `gf` — カーソル下のファイルパスを開く
- `[[` / `]]` — 前後の見出しへジャンプ（Neovim標準の`markdown.vim`）

## あえて入れなかったもの

- `which-key.nvim` — キーマップを覚えるのが目的なので、ポップアップに頼らない
- DAP一式（デバッガ） — この用途では不要。要るようになったら足す
- `neo-tree.nvim` / `barbar.nvim` / `mini.nvim` / `nvim-autopairs` / `indent-blankline.nvim` / `nvim-lint` / `todo-comments.nvim` — netrwや標準機能、あるいは頻度の低さから不採用
- `lazydev.nvim` — このNeovim設定自体をLuaで編集するときのAPI補完が良くなる。この設定を頻繁にいじるなら追加を検討する価値はある
