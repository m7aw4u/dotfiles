# Claude Code ユーザー設定（~/.claude）

このディレクトリのうち、手書きの設定だけを chezmoi で管理している。Claude Code はこの README を読み込まない（読み込むのは `CLAUDE.md`、`rules/`、`@path` で取り込んだファイルだけ）。

## 方針
- ~/.claude には、プロジェクトに依存しない個人設定（言語、文体、回答形式、Git の安全ルール）だけを置く。
- プロジェクト固有の agents、skills、rules は、各プロジェクトの `.claude/` と `AGENTS.md` に置く。
- 複数のプロジェクトで使い回す部品は、将来、個人用プラグインにまとめてプロジェクトごとに有効化する。
- chezmoi で管理するファイルは許可リスト方式で決める。下の表にないものは管理しない。

## 管理しているファイル

| ファイル | 役割 |
|---|---|
| `CLAUDE.md` | 全プロジェクト共通の指示。正本は英語で、Claude Code が毎セッション読み込む |
| `CLAUDE.ja.md` | `CLAUDE.md` の日本語対訳。人が読むためのもので、Claude Code は読み込まない |
| `settings.json` | 権限ルール（permissions）、hook の登録、テーマ、モデル設定、marketplace |
| `hooks/claude-md-ja-sync.sh` | Claude が `CLAUDE.md` を編集したとき、対訳の更新を促す |
| `README.md` | このファイル |

これ以外（`projects/`、`history.jsonl`、`plugins/`、`skills/synced/`、`sessions/`、`backups/` など）は Claude Code が自動生成するデータで、管理しない。`.chezmoiignore` でも除外している。

## settings.json の権限ルール
ルールは deny、ask、allow の順に判定され、最初に一致したものが使われる。CLAUDE.md の Git の段階分けと秘密情報のルールを、仕組みとして強制するためのもの。

| 区分 | 対象 | 意図 |
|---|---|---|
| allow | `git status`、`diff`、`log`、`show`、`branch`、`add`、`stash` | 段階 1。確認なしで実行する |
| ask | `git commit`、`reset`、`rebase`、`merge`、`checkout`、`restore`、`clean`、`stash drop/pop`、`push`、`pull`、`fetch`、`branch -D`、`tag -d`、`rm -rf` | 段階 2・3。必ず確認する。`branch -D` や `stash drop` は allow より先に ask が一致する |
| deny | `.env*`（`.env.example` を除く）、`~/.ssh`、`~/.aws`、`~/.gnupg`、`~/.kube`、`~/.config/gcloud` | 秘密情報を読ませない |
| deny | `git push --force*`、`git push * main`、`git push * master` | Claude には実行させない。必要なときは自分のターミナルで実行する |

- **限界**: Bash のルールはコマンドの書き方で照合する。`git -C . push` や `bash -c '...'` のような別の書き方は一致しないので、Claude の誤操作を防ぐためのものと考える。
- **入れないもの**: `npm test` や `pytest` などのプロジェクト固有のコマンドは、各プロジェクトの `.claude/settings.json` に書く。テストは任意のコードを実行するので、ユーザー設定で一律に許可しない。
- **権限ルールを変えたとき**: CLAUDE.md 3章・4章の記述と食い違わないか確認する。

## 通知
`Notification` hook は、Claude が確認や入力を待っているときに macOS の通知を出す。`osascript` がない環境（Linux など）では何もしない。

## CLAUDE.md を変更するときの手順
1. `~/.claude/CLAUDE.md` を編集する。
2. `~/.claude/CLAUDE.ja.md` を同じ内容に更新する。Claude に編集させた場合は、hook が更新を促す。
3. ソースに取り込む: `chezmoi re-add ~/.claude/CLAUDE.md ~/.claude/CLAUDE.ja.md`
4. コミットする: `cd "$(chezmoi source-path)" && git add dot_claude && git commit`

`CLAUDE.md` だけを変更して対訳を変更していないと、pre-commit hook がコミットを止める。

## 同期の仕組み
- **Claude Code の PostToolUse hook**（`settings.json` に登録）: Claude が `CLAUDE.md` を Edit / Write した直後に、対訳の更新と `chezmoi re-add` を指示する。
- **Git の pre-commit hook**（ソースの `.githooks/pre-commit`）: `dot_claude/CLAUDE.md` だけがステージされたコミットを止める。`run_once_` スクリプトが `core.hooksPath` を設定するので、新しいマシンでも `chezmoi apply` だけで有効になる。

## 状態の確認
- `chezmoi status`: ~/.claude とソースのずれを確認する。`/config` でテーマを変えると `settings.json` がずれるので、その場合は `chezmoi re-add ~/.claude/settings.json`。
- `chezmoi managed --path-style absolute | grep .claude`: 管理対象の一覧を確認する。
