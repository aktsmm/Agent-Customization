# Prompt: Commit & Push

保存していないファイルを保存して commit & Push してください。

## 手順

0. 正しいディレクトリにいることを確認 → `git pull; git branch --show-current; git config user.name` で pull + ブランチ名 + ユーザー名取得
1. VS Code コマンド `workbench.action.files.saveAll` で未保存ファイルを保存
2. `git status --short` で変更確認（変更なければ「Nothing to commit」で終了）
3. `git add .; git commit -m "<コミットメッセージ>"; git push origin <ブランチ名>`（Step 0 で取得したブランチ名を使用）
4. `git remote get-url origin` で Remote リポジトリ URL を表示

## コミットメッセージのフォーマット

以下の形式でコミットメッセージを作成してください：

```
[カテゴリ] 変更内容の要約（25文字以内）- （git config user.name の結果）
```
