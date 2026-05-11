---
description: 保存してコミット（Pushなし）
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# git commit

保存していないファイルを保存して commit してください。

## 手順

1. `Get-Location; git branch --show-current` で現在地とブランチを確認
2. `git config user.name` でユーザー名を取得（コミットメッセージに使用）
3. `git status --short` で変更確認（変更なければ「Nothing to commit」で終了）
4. VS Code コマンド `workbench.action.files.saveAll` で未保存ファイルを保存
5. `git add .; git commit -m "<コミットメッセージ>"` でステージング & コミット

## コミットメッセージのフォーマット

**Conventional Commits** 形式でコミットメッセージを作成してください。

```
<type>(<scope>): <subject> - <user.name>
```

例（`git config user.name` を反映）:

- `feat(auth): ログイン機能を追加 - <user.name>`
- `fix(api): タイムアウトエラーを修正 - <user.name>`
- `docs(readme): セットアップ手順を更新 - <user.name>`
