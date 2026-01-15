# Prompt: Commit

保存していないファイルを保存して commit してください。

## 手順

0. `git config user.name; git status --short` でユーザー名 + 変更確認（変更なければ「Nothing to commit」で終了）
1. VS Code コマンド `workbench.action.files.saveAll` で未保存ファイルを保存
2. `git add .; git commit -m "<コミットメッセージ>"` でステージング & コミット

## コミットメッセージのフォーマット

以下の形式でコミットメッセージを作成してください：

```
[カテゴリ] 変更内容の要約（25文字以内）
```
