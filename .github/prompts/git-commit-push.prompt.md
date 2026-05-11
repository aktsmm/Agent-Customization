---
name: "git-commit-push"
description: 保存してコミット＆プッシュ
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# git commit & push

保存していないファイルを保存して commit & push してください。

## 手順

1. `Get-Location; git branch --show-current` で現在地とブランチを確認
2. `git config user.name` でユーザー名を取得（コミットメッセージに使用）
3. VS Code コマンド `workbench.action.files.saveAll` で未保存ファイルを保存
4. `git status --short` で変更確認（変更なければ「Nothing to commit」で終了）
5. `git add .; git commit -m "<コミットメッセージ>"`
6. `git push`
7. push が rejected された場合: `git pull --rebase --autostash; git push`
8. 完了後、リモートリポジトリの URL をマークダウンリンク形式で表示（例: `[リポジトリ名](https://github.com/owner/repo)`）

## コミットメッセージのフォーマット

**Conventional Commits** 形式でコミットメッセージを作成してください。

```
<type>(<scope>): <subject> - <user.name>
```

例（`git config user.name` を反映）:

- `feat(auth): ログイン機能を追加 - <user.name>`
- `fix(api): タイムアウトエラーを修正 - <user.name>`
- `docs(readme): セットアップ手順を更新 - <user.name>`
