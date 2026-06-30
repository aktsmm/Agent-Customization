---
description: "Git 操作ルール（push 禁止、Conventional Commits、gh CLI）"
applyTo: "**"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Git Operations Instructions

エージェントが Git 操作を安全・一貫して行うための最小ルールです。

## Core Rules

- 明示指示なしの `git push` は禁止（コミットまで可）。
- GitHub への接続で SSH が利用可能なときは、HTTPS より SSH を優先する（既存 remote も必要に応じて SSH へ切り替える）。
- ローカル未展開での軽微操作は `gh api` を優先する。
- 成果物に絶対パスを埋め込まない（相対パスで扱う）。
- `gh issue comment --body` などへ変数を渡すときは、変数定義と実行を同一ターミナル実行で行う。
- Git hook は `.sample` のままでは実行されない。クローン再現性が必要な場合は、repo 管理下（例: `hooks/pre-commit`）に実体を置き、README で `.git/hooks/` へのコピー手順を案内する。
- 公開同期、repo visibility、`.github` / `.vscode` の公開判断は、実行前に対象と公開範囲を確認する。

## Release Sanity

- release / publish 前に、対象 version が registry に既に存在しないかを確認する。存在する場合は同じ version を再利用せず、HEAD に合わせて patch 以上を上げる。
- release tag を作る前に、その tag が指す commit と現在の HEAD を比較する。既存 tag が HEAD より古いなら tag の付け替えではなく version bump で進める。
- package publish では ignore 設定や packer の想定を信じ切らず、実 tarball の中身を列挙して runtime artifact だけが入っていることを確認する。
- npm package の `files` を使う repo では、必要な runtime artifact を include pattern で明示し、sourcemap などの開発資材が混入しないことを pack 後に確認する。
- `vsce publish` の直後は `vsce show --json` や Marketplace の version 表示が stale なことがある。publish 成功出力、remote tag、GitHub Release、Marketplace page の更新時刻など別経路の証跡を先に確認し、stale 表示だけで再 publish や追加 version bump をしない。

## Conventional Commits

- 形式: `<type>(<scope>): <subject>`
- 主な type: `feat` `fix` `docs` `refactor` `test` `chore`
- subject は命令形・簡潔・文末ピリオドなし。
- 必要なら ` - <user.name>` を末尾に付与してよい。
- PowerShell で `git commit -m` を使う場合、メッセージはシングルクォートで囲む（`(scope)` の括弧がサブ式として評価されるため）。

## Destructive Operations

- `git filter-repo` / `git rebase -i` / `git reset --hard` 前に未コミット変更を必ず確定する。
- `git restore <file>` / `git checkout -- <file>` は、そのファイル内の無関係な未コミット変更も巻き戻す。restore 後は対象ファイルの diff を再確認し、巻き戻したくない変更（例: 別作業の編集）が消えていないか確認する。
- `git stash` だけに依存しない。
- 大量の `git status` 出力に対しては、`git add -A` 前に「自分が触ったもの」「別ツール由来（skill 同期、formatter、別 IDE）」「未追跡の一時ファイル」を分類してユーザーに確認する。混在 dirty を一括で commit すると、後で範囲を分離するのが困難になる。

## Encoding

- 日本語を含むファイルは `UTF-8`（PowerShell では `Get-Content -Raw -Encoding UTF8`）で扱う。
- GitHub API 向け JSON は BOM なし UTF-8 を使う。

## gh CLI

- private repo で `Could not resolve to a Repository` や scope 不足が出たら、repo 名や remote を疑う前に `gh auth status` で active credential を確認する。
- `gh` を複数アカウントで使っている環境では、release 作成や release asset 操作の前に `gh auth status` で **active account** を確認する。対象 repo の owner ではない account が active だと、`gh release create` が `workflow scope may be required` などの分かりにくい権限エラーで失敗することがある。
- `gh repo view` や `gh api repos/<owner>/<repo>` は成功するのに `git clone` / `git push` が `Repository not found` になる場合は、Git transport が別 credential を使っている可能性を疑う。`gh auth setup-git` や `gh api` の permissions で切り分け、小さな同期なら Git Data API 経路へ切り替えてよい。
- `GITHUB_TOKEN` / `GH_TOKEN` が設定されていると、keyring に保存された高権限認証より優先されることがある。
- そのシェルだけ保存済み認証を使いたい場合は、`$env:GITHUB_TOKEN=$null; $env:GH_TOKEN=$null` を設定してから `gh` を再実行してよい。
- private repo の PR/Issue 確認で認証が怪しいときは、`gh pr list -R <owner>/<repo> ...` のように `-R` を明示して切り分けてよい。
- `gh api` / `gh issue comment` 等で `EOF` エラーが出た場合は、そのままリトライで解決することが多い（一時的な接続問題）。
- Issue コメント削除（`gh api -X DELETE`）が失敗した場合は、`gh issue comment --edit-last --body "(deleted)"` で内容を差し替えてからリトライする。
- 長いマークダウンを `--body` で直接渡すとシェルの問題が起きやすいので、`--body-file` でファイル経由で渡す。

