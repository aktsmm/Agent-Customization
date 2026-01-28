---
description: 保存してコミット＆プッシュ
---

<!-- syncToGlobal: true -->

# Quick Commit & Push

1. `workbench.action.files.saveAll` で保存
2. `git pull; git add .; git diff --staged --stat` を実行
3. 変更があれば Conventional Commits 形式（`<type>(<scope>): <subject> - <user.name>`）でメッセージ生成
4. `git commit -m "<メッセージ>"; git push origin $(git branch --show-current)`
5. 完了後リモート URL をリンク表示
