---
name: "git-pull"
description: リモートからPullして変更箇所を表示
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# git pull

リモートレポジトリの最新状態に合わせて(Pull)、変更箇所を教えてください。

## 手順

1. `Get-Location; git branch --show-current` で現在地とブランチを確認
2. `git pull --autostash`
3. `git log --oneline -5` で直近 5 件のコミットを表示
