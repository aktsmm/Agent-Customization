# Prompt: Commit

保存していないファイルを保存して commit してください。

## 手順

0. **ワークスペース確認**: `Get-Location; git remote -v` で現在地とリモートリポジトリを確認し、意図したリポジトリにいることを確認（違う場合は `Set-Location <正しいパス>` で移動）
1. `git config user.name; git status --short` でユーザー名 + 変更確認（変更なければ「Nothing to commit」で終了）
2. VS Code コマンド `workbench.action.files.saveAll` で未保存ファイルを保存
3. `git add .; git commit -m "<コミットメッセージ>"` でステージング & コミット

## コミットメッセージのフォーマット

以下の形式でコミットメッセージを作成してください：
**Conventional Commits** 形式でコミットメッセージを作成してください。
詳細は [git.instructions.md](../instructions/dev/git.instructions.md) を参照。

```
[カテゴリ] 変更内容の要約（25文字以内）- （git config user.name の結果）
```
