# Prompt: Commit & Push

保存していないファイルを保存して commit & Push してください。

## 手順

0. `git config user.name; git remote get-url origin; git pull; git branch --show-current; git log --oneline -5` でユーザー名 + Remote URL + pull + ブランチ名 + 直近5件のコミット（変更サマリ）を一括取得
1. VS Code コマンド `workbench.action.files.saveAll` で未保存ファイルを保存
2. `git status --short` で変更確認（変更なければ「Nothing to commit」で終了）
3. `git add .; git commit -m "<コミットメッセージ>"; git push origin <ブランチ名>`（Step 0 で取得したブランチ名を使用）

## コミットメッセージのフォーマット

以下の形式でコミットメッセージを作成してください：

```
[カテゴリ] 変更内容の要約（25文字以内）- （git config user.name の結果）
```
