---
name: "wrap-up-work"
description: "終了前の保存とUI整理を一括実行"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# wrap up work

順に実行する。

- 順番固定
- 未対応は skipped
- 保存不能なら stop
- 最後は 1 行で結果だけ返す

1. `workbench.action.files.saveAll` — 全ファイル保存
2. `workbench.files.action.collapseExplorerFolders` — フォルダツリーを折りたたむ
3. `notifications.clearAll` — 通知を全クリア
4. `workbench.action.closeAllEditors` — 全エディタを閉じる
5. `workbench.action.closePanel` — 下部パネルを閉じる
6. `workbench.action.closeSidebar` — サイドバーを閉じる
7. `workbench.action.terminal.killAll` — ターミナル全削除
