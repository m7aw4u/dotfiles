# Vim設定

普段の編集はNeovim（`~/.config/nvim/`、詳しくはそちらのREADME参照）を使う。この`~/.vimrc` + `~/.vim/`は「Neovimが使えない/使わないときにたまに開くかもしれない」**フォールバック用途**という位置づけ。以前はNERDTree・vim-airline・vim-lsp+asyncomplete一式など約20個のプラグインが精査されずに積まれていたが、2026-09に必要最小限へ作り直した。

## 採用方針

Neovim側と同じく「標準機能で代替できるものはプラグインを使わない」が基本線。加えてVim側は用途がフォールバックであることから、さらに一段絞っている。

- LSP/補完機能は入れない（`vim-lsp`, `asyncomplete.vim`一式を削除）。LSPが要る作業はNeovim側に任せる。
- ファイルツリー・ステータスラインなどのUI強化系も入れない（NERDTree→netrw、airline→標準statusline）。
- 残すのは「編集そのものを強化し、vanilla Vimの標準機能では代替困難」なプラグインのみ。

## プラグイン一覧（4個）

| プラグイン | 採用理由 |
|---|---|
| `tpope/vim-surround` | 囲み文字の追加・変更・削除 |
| `tpope/vim-commentary` | コメントの一括トグル（vanilla Vimに相当機能なし） |
| `tpope/vim-sleuth` | ファイルごとのインデント自動検出 |
| `markonm/traces.vim` | `:s`置換のライブプレビュー（vanilla Vimには`inccommand`相当がない） |

## ネイティブ機能で済ませているもの

- ファイルツリー: `<C-b>` → `:Lexplore`（netrw）
- 括弧・クォートの自動補完: プラグインなしの手書きキーマップ（`.vimrc`内）
- インデント: `filetype plugin indent on` の言語別インデントに一本化
