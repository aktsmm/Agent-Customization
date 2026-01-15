# Prompt: Cleanup Session

セッション終了時のクリーンアップ。

## コマンド実行

以下を順番に実行：

1. `inlineChat.acceptChanges`
2. `workbench.action.files.saveAll`
3. `workbench.action.closeUnmodifiedEditors`
4. `workbench.action.chat.clearHistory` → **Delete All** を押す
5. `workbench.action.chat.newChat` → 手動で **+** ボタン or `Ctrl+Shift+P` → "Chat: New Chat"
