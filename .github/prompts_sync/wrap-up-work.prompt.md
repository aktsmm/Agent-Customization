---
description: セッション終了時のクリーンアップ
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Prompt: Cleanup Session

セッション終了時のクリーンアップ。

## セッション終了チェックリスト

実行前に確認：

- [ ] 未保存ファイルがないか
- [ ] エラーが残っていないか（`get_errors` で確認）
- [ ] コミットすべき変更があるか（`git status`）
- [ ] TODO リストが完了しているか
- [ ] 重要な学びがあれば `export-log.prompt.md` でエクスポート済みか

## コマンド実行

以下を順番に実行：

1. `inlineChat.acceptChanges`
2. `workbench.action.files.saveAll`
3. `workbench.action.closeUnmodifiedEditors`
4. `workbench.action.chat.newChat`

> 💡 チャット履歴のクリアが必要な場合は手動で `Ctrl+Shift+P` → "Chat: Clear All History" を実行してください。
