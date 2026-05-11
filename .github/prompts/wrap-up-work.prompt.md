---
description: "セッション終了時のクリーンアップ（保存・閉じる・送るなどを一括実行）"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# wrap up work

セッション終了時のクリーンアップ。以下を順番に実行：

実行ルール:

- **この順番を維持**（途中で止まらず最後まで進める）
- コマンドが実行できない/見つからない場合は **スキップして次へ**
- 全体が終わったら **1行だけ**で結果を返す（例: `Cleanup 完了（skipped: 1）`）

1. `workbench.action.files.saveAll` — 全ファイル保存
2. `workbench.files.action.collapseExplorerFolders` — フォルダツリーを折りたたむ
3. `workbench.action.terminal.killAll` — ターミナル全削除
4. `workbench.action.closeAllEditors` — 全エディタを閉じる
5. `workbench.action.closePanel` — 下部パネルを閉じる
6. `workbench.action.closeSidebar` — サイドバーを閉じる
7. `notifications.clearAll` — 通知を全クリア
8. `workbench.action.chat.newChat` — 新しいチャットを開始（※これが最後のステップ）
