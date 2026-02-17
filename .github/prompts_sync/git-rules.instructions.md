---
---

<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Git 操作ルール

- **明示的な指示がない限り `git push` は禁止**。コミットまでは可、プッシュはユーザーの明示的な許可を得てから行うこと。
- コミットメッセージは Conventional Commits 形式（`feat:`, `fix:`, `docs:`, `chore:` 等）で記述する。

- **ローカルでリポジトリを開いていない場合は gh api を使う**。ファイルの作成・更新・削除などの軽い操作でわざわざクローンしない。gh api repos/{owner}/{repo}/contents/{path} で直接操作すること。
