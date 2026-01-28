---
description: リモートからPullして変更箇所を表示
---

<!-- syncToGlobal: true -->

# Prompt: Pull

リモートレポジトリの最新状態に合わせて(Pull)、変更箇所を教えてください。

## 手順

> ワークスペース確認の詳細は [terminal.instructions.md](../instructions/dev/terminal.instructions.md) を参照

0. **ワークスペース確認**: `Get-Location; git remote -v` で現在地とリモートリポジトリを確認（違う場合は `Set-Location <正しいパス>` で移動）
1. `git pull` でリモートから取得
2. `git log --oneline -5` で直近 5 件のコミットを表示（変更サマリ）
