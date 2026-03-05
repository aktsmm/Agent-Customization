---
---

<!-- author: aktsmm -->

# VS Code 環境情報

## ファイルパス

### チャット画像の保存先

- GitHub Copilot Chat に貼り付けた画像は以下に保存される:
  - `%APPDATA%\Code\User\workspaceStorage\vscode-chat-images\`
- ファイル名形式: `image-{timestamp}.png`
- チャットで画像を参照する際はこのパスを使用する
- 必要に応じて、ワークスペース内に用途に合ったファイル名でコピーして使用してよい

### グローバル Prompts / Agents / Instructions

- `%APPDATA%\Code\User\prompts\` 配下に配置
- ワークスペース固有のものは各リポの `.github/prompts/` に配置

## 拡張機能ストレージ

- `%APPDATA%\Code\User\globalStorage\` — グローバル拡張機能データ
- `%APPDATA%\Code\User\workspaceStorage\` — ワークスペース別データ
