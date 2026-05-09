---
description: "VS Code 環境の保存先、User Data、workspaceStorage などの実用メモ"
applyTo: "**"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# VS Code 環境情報

VS Code 環境でよく参照する保存先と配置場所のメモ。

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

## Notes

- GitHub CLI 認証トラブルの切り分けは `git.instructions.md` を参照する。
- `rg` の導入、UTF-8、Web 検索 fallback などのターミナル運用は `terminal.instructions.md` を参照する。

## Workspace Tasks Rule

- `.vscode/tasks.json` の `command` や `args` にはローカル絶対パス（例: `d:/...`）を直書きしない。
- ワークスペース配下を参照するパスは `${workspaceFolder}` を優先する。
- PowerShell の `Set-Location` でも固定パスではなく `Set-Location '${workspaceFolder}'` を使う。
- 例外が必要な場合は、理由をタスクの `label` か近傍コメントで明示する。
