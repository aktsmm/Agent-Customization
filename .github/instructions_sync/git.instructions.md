---
description: "Git 操作ルール（Conventional Commits、Push 禁止、gh CLI、LICENSE 規約）"
applyTo: "**"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Git Instructions

エージェントが Git 操作を安全・一貫して行うための最小ルールです。

## 1. 公開同期の最優先判断

- 最初に「この repo は `.github` を公開運用する目的か」を判定する。
- 判定できなければ必ずユーザーに質問する。
- 既定は非公開: `.github` / `.vscode` は通常追跡しない。

## 2. 1回確認したら再確認しない

- 初回確認結果は repo ローカルの `.hiker/repo-visibility-policy.json` に保存する。
- 参照キーは `origin URL` 推奨。
- 方針変更の明示指示がない限り、同じ質問を繰り返さない。
- `.hiker/` は `.gitignore` 対象にする。

## 3. 公開しない方針の運用

- 追跡を止めるときは `git rm --cached` でインデックスから外し、`.gitignore` に `/.github/` `/.vscode/` `/.hiker/` を追加する。
- ローカル実ファイルは削除しない。

## 3.1 追跡対象の最小化（公開前）

- 追跡するのは「リポジトリ公開に必要なファイル」だけにする。
- `.github` は workflow / automation / 運用上必要なメタデータのみ追跡し、不要な補助資料は追跡しない。
- 不要ファイルは `.gitignore` に追加し、すでに追跡済みなら `git rm --cached` で追跡解除する。

## 4. 既に公開してしまった場合

- 通常は「今後同期しない」対応で十分（履歴は残す）。
- 履歴から削除するのは**ユーザーの明示指示があるときだけ**。
- 履歴改変時はバックアップを取ってから `git filter-repo` + `force push` を実施し、共同開発者へ再同期手順を案内する。
- 必要ならシークレットを失効・再発行する。

## 5. 基本 Git ルール

- 明示指示なしの `git push` は禁止（コミットまで可）。
- GitHub への接続で SSH が利用可能なときは、HTTPS より SSH を優先する（既存 remote も必要に応じて SSH へ切り替える）。
- ローカル未展開での軽微操作は `gh api` を優先する。
- 成果物に絶対パスを埋め込まない（相対パスで扱う）。
- `gh issue comment --body` などへ変数を渡すときは、変数定義と実行を同一ターミナル実行で行う。

## 6. Conventional Commits（要点）

- 形式: `<type>(<scope>): <subject>`
- 主な type: `feat` `fix` `docs` `refactor` `test` `chore`
- subject は命令形・簡潔・文末ピリオドなし。
- 必要なら ` - <user.name>` を末尾に付与してよい。

## 7. 破壊的操作の注意

- `git filter-repo` / `git rebase -i` / `git reset --hard` 前に未コミット変更を必ず確定する。
- `git stash` だけに依存しない。

## 8. aktsmm 公開リポ既定

- 新規公開 repo は原則 CC BY-NC-SA 4.0 LICENSE を採用する。
- 例外: `Agent-Skills` と `ghc_template`。

## 9. 文字エンコーディング

- 日本語を含むファイルは `UTF-8`（PowerShell では `Get-Content -Raw -Encoding UTF8`）で扱う。
- GitHub API 向け JSON は BOM なし UTF-8 を使う。

## 10. gh CLI のエラーハンドリング

- `gh api` / `gh issue comment` 等で `EOF` エラーが出た場合は、そのままリトライで解決することが多い（一時的な接続問題）。
- Issue コメント削除（`gh api -X DELETE`）が失敗した場合は、`gh issue comment --edit-last --body "(deleted)"` で内容を差し替えてからリトライする。
- 長いマークダウンを `--body` で直接渡すとシェルの問題が起きやすいので、`--body-file` でファイル経由で渡す。
