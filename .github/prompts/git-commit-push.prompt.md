---
name: "git-commit-push"
description: 保存してコミット＆プッシュ
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# git commit & push

保存していないファイルを保存して commit & push してください。

## 手順

1. `Get-Location; git branch --show-current` で現在地とブランチを確認
2. `git config user.name` でユーザー名を取得（コミットメッセージに使用）
3. VS Code コマンド `workbench.action.files.saveAll` で未保存ファイルを保存
4. `git fetch origin; git status -sb` で同期状態と変更を確認する（変更なければ「Nothing to commit」で終了）
5. `master` が behind の場合は、作業ツリーが clean なときだけ `git pull --ff-only` を実行する。分岐している場合や作業ツリーが dirty の場合は、自動 rebase しない
6. 変更が複数の独立した作業に混在している場合は `git add .` を使わず、対象パスごとにコミットを分ける。単一作業なら `git add -- <対象パス>; git diff --cached --check; git commit -m "<コミットメッセージ>"`
7. `git push`
8. push が rejected された場合:
	- `git fetch origin; git status -sb` で ahead / behind と作業ツリーを確認する
	- 作業ツリーが clean で fast-forward 可能なら `git pull --ff-only; git push` を実行する
	- 分岐している場合は、自動で `git pull --rebase --autostash` を実行しない。競合対象と rebase の必要性を報告し、ユーザーの承認後に専用の安全手順で進める
9. 完了後、リモートリポジトリの URL をマークダウンリンク形式で表示（例: `[リポジトリ名](https://github.com/owner/repo)`）

## コミットメッセージのフォーマット

**Conventional Commits** 形式でコミットメッセージを作成してください。

```
<type>(<scope>): <subject> - <user.name>
```

例（`git config user.name` を反映）:

- `feat(auth): ログイン機能を追加 - <user.name>`
- `fix(api): タイムアウトエラーを修正 - <user.name>`
- `docs(readme): セットアップ手順を更新 - <user.name>`
