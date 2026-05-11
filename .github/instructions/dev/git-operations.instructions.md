---
description: "Git 操作ルール（push 禁止、Conventional Commits、gh CLI）"
applyTo: "**"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Git Operations Instructions

エージェントが Git 操作を安全・一貫して行うための最小ルールです。
公開判断（repo visibility / `.github` / `.vscode` の公開可否）は [git-publish-policy.instructions.md](git-publish-policy.instructions.md) を参照してください。

## Core Rules

- 明示指示なしの `git push` は禁止（コミットまで可）。
- GitHub への接続で SSH が利用可能なときは、HTTPS より SSH を優先する（既存 remote も必要に応じて SSH へ切り替える）。
- ローカル未展開での軽微操作は `gh api` を優先する。
- 成果物に絶対パスを埋め込まない（相対パスで扱う）。
- `gh issue comment --body` などへ変数を渡すときは、変数定義と実行を同一ターミナル実行で行う。
- 公開同期、repo visibility、`.github` / `.vscode` の公開判断は `git-publish-policy.instructions.md` を参照する。

## Conventional Commits

- 形式: `<type>(<scope>): <subject>`
- 主な type: `feat` `fix` `docs` `refactor` `test` `chore`
- subject は命令形・簡潔・文末ピリオドなし。
- 必要なら ` - <user.name>` を末尾に付与してよい。

## Destructive Operations

- `git filter-repo` / `git rebase -i` / `git reset --hard` 前に未コミット変更を必ず確定する。
- `git stash` だけに依存しない。

## Encoding

- 日本語を含むファイルは `UTF-8`（PowerShell では `Get-Content -Raw -Encoding UTF8`）で扱う。
- GitHub API 向け JSON は BOM なし UTF-8 を使う。

## gh CLI

- private repo で `Could not resolve to a Repository` や scope 不足が出たら、repo 名や remote を疑う前に `gh auth status` で active credential を確認する。
- `GITHUB_TOKEN` / `GH_TOKEN` が設定されていると、keyring に保存された高権限認証より優先されることがある。
- そのシェルだけ保存済み認証を使いたい場合は、`$env:GITHUB_TOKEN=$null; $env:GH_TOKEN=$null` を設定してから `gh` を再実行してよい。
- private repo の PR/Issue 確認で認証が怪しいときは、`gh pr list -R <owner>/<repo> ...` のように `-R` を明示して切り分けてよい。
- `gh api` / `gh issue comment` 等で `EOF` エラーが出た場合は、そのままリトライで解決することが多い（一時的な接続問題）。
- Issue コメント削除（`gh api -X DELETE`）が失敗した場合は、`gh issue comment --edit-last --body "(deleted)"` で内容を差し替えてからリトライする。
- 長いマークダウンを `--body` で直接渡すとシェルの問題が起きやすいので、`--body-file` でファイル経由で渡す。

## See Also

- [git-publish-policy.instructions.md](git-publish-policy.instructions.md) - 公開同期と visibility 判断のルール
