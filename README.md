# Personal Dotfiles

chezmoi で管理している個人のdotfiles

---

## 目次

- [管理しているファイル](#管理しているファイル)
- [初期導入（新しいマシン）](#初期導入新しいマシン)
- [既存dotfileがあるマシンへの適用](#既存dotfileがあるマシンへの適用)
- [日常的な使い方](#日常的な使い方)
- [コマンドリファレンス](#コマンドリファレンス)
- [仕組みの理解](#仕組みの理解)
- [トラブルシューティング](#トラブルシューティング)

---

## 管理しているファイル

| ファイル | 説明 |
|---|---|
| `~/.zshrc` | zsh設定（OS別に自動切り替え） |
| `~/.tmux.conf` | tmux設定 |
| `~/.vimrc` | vim設定（フォールバック用途、詳細は[`dot_vim/README.md`](dot_vim/README.md)） |
| `~/.vim/` | vim関連ファイル |
| `~/.config/nvim/` | neovim設定（メインエディタ、詳細は[`dot_config/nvim/README.md`](dot_config/nvim/README.md)） |

Vim/Neovimとも「標準機能で代替できるものはプラグインを使わない、代替困難なものだけプラグインにする」という方針で必要最小限に構成している。プラグインを足したくなったら各READMEの採用方針を先に確認すること。

**管理対象でないもの（Gitにコミットされない）:**
- `~/.zshrc.local` → マシン固有の設定（プロキシ、パス等）を書く場所

---

## 初期導入（新しいマシン）

> **前提**: gitがインストール済みであること

### ステップ 1: chezmoiをインストール

OSに合わせて以下を実行する。

**macOS**
```bash
brew install chezmoi
```

**Arch Linux**
```bash
sudo pacman -S chezmoi
```

**その他/汎用（curl が使えれば動く）**
```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
# → ~/.local/bin/chezmoi にインストールされる
# PATHに追加が必要な場合: export PATH="$HOME/.local/bin:$PATH"
```

---

### ステップ 2: リポジトリを初期化

```bash
chezmoi init git@github.com:wataru-script/dotfiles.git
```

> `~/.local/share/chezmoi/` にリポジトリがクローンされる。
> SSHキーがない場合はHTTPS版を使う:
> `chezmoi init https://github.com/wataru-script/dotfiles.git`

---

### ステップ 3: 差分を確認してから適用

```bash
# 何が変更/作成されるか確認（実際には何も変更しない）
chezmoi diff

# 問題なければ適用
chezmoi apply -v
```

`apply` 実行時に `run_onchange_install-packages.sh.tmpl` が自動実行され、**dotfilesで使用するソフトウェアが一括インストールされる**（macOS: Homebrew、Arch Linux: pacman）。インストール対象は同ファイルにハードコードされている。

---

### ステップ 4: マシン固有の設定を追加（任意）

会社専用のプロキシや、このマシンだけで使うエイリアスなどは `~/.zshrc.local` に書く。

```bash
# ファイルを作成して編集
touch ~/.zshrc.local
```

```bash
# ~/.zshrc.local の例
export COMPANY_PROXY="http://proxy.example.com:8080"
alias work="cd ~/Projects/work"
export EDITOR="code"
```

このファイルは `.chezmoiignore` で除外されているため、Gitにはコミットされない。

---

## 既存dotfileがあるマシンへの適用

> すでに `~/.zshrc` 等が存在するマシンにこのリポジトリを適用する手順。

### ステップ 1: chezmoiをインストール

上記「[初期導入 ステップ1](#ステップ-1-chezmoiをインストール)」と同じ。

---

### ステップ 2: リポジトリを初期化（適用はまだしない）

```bash
chezmoi init git@github.com:wataru-script/dotfiles.git
```

---

### ステップ 3: 既存ファイルとの差分を確認する

```bash
chezmoi diff
```

出力例（既存の `.zshrc` と差分がある場合）:
```
--- a/home/username/.zshrc
+++ b/home/username/.zshrc
-既存の設定
+このリポジトリの設定
```

**差分の見方:**
- `-` が付いた行 → 現在のファイルにあるが、リポジトリには**ない**もの
- `+` が付いた行 → リポジトリにあって、現在のファイルに**ない**もの

---

### ステップ 4: 方針を決めて適用する

#### パターンA: リポジトリの設定で完全に上書きする（推奨）

現在の dotfile をバックアップしてから上書き。

```bash
# バックアップ
cp ~/.zshrc ~/.zshrc.bak
cp ~/.tmux.conf ~/.tmux.conf.bak  # 存在する場合

# リポジトリの内容で上書き
chezmoi apply --force -v
```

---

#### パターンB: ファイルごとに確認しながら適用する

```bash
# 差分を見てから1ファイルずつ適用
chezmoi diff ~/.zshrc
chezmoi apply ~/.zshrc

chezmoi diff ~/.vimrc
chezmoi apply ~/.vimrc
```

---

#### パターンC: 既存設定をリポジトリにマージしたい

現在の設定から引き継ぎたい内容がある場合。

```bash
# ステップ1: まず既存ファイルをリポジトリに取り込む（上書きはしない）
chezmoi add ~/.zshrc

# ステップ2: ソースファイルを編集してマージ
chezmoi edit ~/.zshrc
# エディタが開くので、既存の設定とリポジトリの設定を手動でマージする

# ステップ3: 適用
chezmoi apply -v
```

---

### ステップ 5: マシン固有の設定を移行する

既存の `.zshrc` にマシン固有の設定（会社のプロキシ、個別のエイリアス等）がある場合は、
それらを `~/.zshrc.local` に移動する。

```bash
# ~/.zshrc.local を作成して、既存の個別設定を移行
touch ~/.zshrc.local
# 既存 .zshrc から個別設定を cut & paste
```

---

### ステップ 6: 動作確認

```bash
# 新しいシェルを開いて動作確認
exec zsh

# または chezmoi で管理中のファイル一覧を確認
chezmoi managed
```

---

## 日常的な使い方

### 設定ファイルを編集したい

```bash
# ソースディレクトリをエディタで開く
code $(chezmoi source-path)

# または1ファイルだけ編集
chezmoi edit ~/.zshrc

# 変更を適用（忘れずに）
chezmoi apply -v
```

> `chezmoi edit` はソースファイル（`~/.local/share/chezmoi/`以下）を開く。
> 直接 `~/.zshrc` を編集しても、`chezmoi apply` で上書きされるため意味がない。

---

### 他のマシンの変更を取り込みたい

```bash
# リモートの最新を取得して適用（git pull + chezmoi apply の一括実行）
chezmoi update
```

---

### 変更をGitにプッシュしたい

```bash
cd $(chezmoi source-path)
git add .
git commit -m "変更内容のメモ"
git push
```

---

### 新しいファイルをchezmoiで管理したい

```bash
# ファイルをchezmoiに追加（ソースディレクトリにコピーされる）
chezmoi add ~/.gitconfig

# ソースディレクトリでコミット
cd $(chezmoi source-path)
git add .
git commit -m "Add gitconfig"
git push
```

---

### パッケージを追加/削除したい

```bash
# インストールスクリプトを編集
chezmoi edit run_onchange_install-packages.sh.tmpl
# または
code $(chezmoi source-path)/run_onchange_install-packages.sh.tmpl

# 適用（ファイルが変更されていれば自動でスクリプトが実行される）
chezmoi apply -v
```

---

## コマンドリファレンス

### 確認系

```bash
chezmoi source-path              # ソースディレクトリの場所を表示
chezmoi managed                  # 管理対象ファイルの一覧
chezmoi diff                     # ホームとソースの差分を表示
chezmoi status                   # 変更のあるファイル一覧
```

### 編集・適用

```bash
chezmoi edit ~/.zshrc            # ファイルを編集（ソースを直接開く）
chezmoi apply -v                 # 全体を適用（-v で詳細表示）
chezmoi apply ~/.zshrc           # 特定ファイルのみ適用
chezmoi apply --dry-run -v       # ドライラン（実際には変更しない）
chezmoi apply --force            # 競合を無視して強制上書き
```

### 同期

```bash
chezmoi update                   # git pull + apply を一括実行
```

### 追加・削除

```bash
chezmoi add ~/.gitconfig         # ファイルを管理対象に追加
chezmoi forget ~/.gitconfig      # 管理対象から外す（ファイル自体は消えない）
```

### Git操作（ソースディレクトリ内）

```bash
chezmoi git status               # ソースディレクトリのgit status
chezmoi git -- add .             # git add（-- 以降はgitコマンドに渡る）
chezmoi git -- commit -m "msg"   # git commit
chezmoi git -- push              # git push
```

---

## 仕組みの理解

### ファイル名の命名規則

| ソースでの名前 | ホームでの名前 | 意味 |
|---|---|---|
| `dot_zshrc.tmpl` | `~/.zshrc` | `dot_` → `.` に変換、`.tmpl` → テンプレート処理 |
| `dot_tmux.conf` | `~/.tmux.conf` | `dot_` → `.` に変換 |
| `run_onchange_*.sh.tmpl` | 実行される | `run_onchange_` → 変更時に自動実行 |

### OS別の設定はどう管理されている？

`.tmpl` ファイル内で Go テンプレート構文を使ってOS別に条件分岐している:

```go-template
{{ if eq .chezmoi.os "darwin" -}}
# macOS専用の設定
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
{{ else if eq .chezmoi.os "linux" -}}
# Linux専用の設定
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
{{ end -}}
```

`chezmoi apply` 時に実行中のOSに合わせた内容でファイルが生成される。

### マシン固有の設定との使い分け

| 設定の種類 | 管理方法 |
|---|---|
| OS依存（macOS/Linux共通） | `.tmpl` でテンプレート分岐 |
| マシン固有（会社のプロキシ等） | `~/.zshrc.local`（Gitに入れない） |

### パッケージの自動インストール

`run_onchange_install-packages.sh.tmpl` は `chezmoi apply` 時に
**ファイル内容が変更されたとき**だけ自動実行される。
パッケージを追加したらファイルを保存してコミットし、他マシンで `chezmoi update` すると
自動的にパッケージがインストールされる。

---

## トラブルシューティング

### `chezmoi apply` で既存ファイルとの競合が起きる

```bash
# 差分を確認
chezmoi diff

# リポジトリの内容で上書きしてOKなら
chezmoi apply --force

# ファイルごとに個別に処理したいなら
chezmoi apply ~/.zshrc  # 1ファイルずつ確認しながら適用
```

---

### パッケージインストールエラー

**macOS:**
```bash
brew update && brew doctor
# エラーがなくなったら再実行
chezmoi apply -v
```

**Arch Linux:**
```bash
sudo pacman -Syu
chezmoi apply -v
```

---

### `chezmoi` コマンドが見つからない

汎用インストーラを使った場合、`~/.local/bin` にインストールされる。

```bash
export PATH="$HOME/.local/bin:$PATH"
```

永続化するには `~/.zshrc.local` に追記する。

---

### ソースディレクトリが見つからない / 初期化されていない

```bash
chezmoi source-path  # 場所を確認（エラーが出たら未初期化）

# 未初期化の場合
chezmoi init git@github.com:wataru-script/dotfiles.git
```

---

### 設定を完全にリセットして最初からやり直したい

```bash
# chezmoiのデータを完全削除
rm -rf ~/.local/share/chezmoi ~/.config/chezmoi

# 再初期化
chezmoi init git@github.com:wataru-script/dotfiles.git
chezmoi apply -v
```

---

### `chezmoi edit` で開いた後に apply を忘れた

編集後に `chezmoi diff` を実行すると差分が残っているかわかる。

```bash
chezmoi diff        # 差分があれば apply が必要
chezmoi apply -v    # 適用
```

---

## 機微情報の扱い

**現在の方針**: 機微情報は `~/.zshrc.local` に記載（Gitにコミットしない）

```bash
# ~/.zshrc.local に書く（コミットされない）
export API_KEY="xxx"
export COMPANY_PROXY="http://proxy.example.com:8080"
```

**将来的な選択肢**: 1Password連携
- API Key、パスワード等を1Passwordで管理
- chezmoiの1Password連携機能でテンプレートから参照
- 参考: [chezmoi 1Password integration](https://www.chezmoi.io/user-guide/password-managers/1password/)

---

## 参考情報

- **公式ドキュメント**: https://www.chezmoi.io/
- **このリポジトリ**: https://github.com/wataru-script/dotfiles
