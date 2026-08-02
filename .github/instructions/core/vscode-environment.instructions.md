---
description: "VS Code 内部パス（User Data / workspaceStorage / globalStorage）を参照するときに使う。保存先の SSOT として読み出すための手動参照メモ"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# VS Code 環境情報

VS Code 環境でよく参照する保存先と配置場所のメモ。「どこに何があるか」の SSOT として使う。

## ファイルパス

### チャット画像の保存先

- GitHub Copilot Chat に貼り付けた画像は、以下を最優先の保存先として扱う:
  - `%APPDATA%\Code\User\workspaceStorage\vscode-chat-images\`
- ファイル名形式: `image-{timestamp}.png`
- チャットで画像を参照・取り込むときは、まずこの場所を確認し、添付時刻に近いファイルを候補にする。候補が複数なら寸法や画像内容で照合する。Screenpresso は、ユーザーが同ツールで撮影したと示した場合、またはこの場所に一致候補がない場合だけ確認する。
- 必要に応じて、ワークスペース内に用途に合ったファイル名でコピーして使用してよい

### グローバル Prompts / Agents / Instructions

- `%APPDATA%\Code\User\prompts\` 配下に配置
- ワークスペース固有のものは各リポの `.github/prompts/` に配置

## 拡張機能ストレージ

- `%APPDATA%\Code\User\globalStorage\` — グローバル拡張機能データ
- `%APPDATA%\Code\User\workspaceStorage\` — ワークスペース別データ

## Notes

- GitHub CLI 認証トラブル、PowerShell 運用、Web 検索 fallback の詳細は扱わない。
