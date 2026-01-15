# Prompt: Commit & Push

保存していないファイルを保存して commit & Push してください。

## 手順

0. **ワークスペース確認**: `Get-Location; git remote -v` で現在地とリモートリポジトリを確認し、意図したリポジトリにいることを確認（違う場合は `Set-Location <正しいパス>` で移動）
1. `git config user.name; git remote get-url origin; git pull; git branch --show-current; git log --oneline -5` でユーザー名 + Remote URL + pull + ブランチ名 + 直近 5 件のコミット（変更サマリ）を一括取得
2. VS Code コマンド `workbench.action.files.saveAll` で未保存ファイルを保存
3. `git status --short` で変更確認（変更なければ「Nothing to commit」で終了）
4. `git add .; git commit -m "<コミットメッセージ>"; git push origin <ブランチ名>`（Step 1 で取得したブランチ名を使用）

## コミットメッセージのフォーマット

以下の形式でコミットメッセージを作成してください：

```
[カテゴリ] 変更内容の要約（25文字以内）- （git config user.name の結果）
```
