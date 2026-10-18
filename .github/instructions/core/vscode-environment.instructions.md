---
description: "VS Code 内部パス（globalStorage / workspaceStorage / agentSessionData / logs）と、チャットに貼り付けた画像の実ファイルの保存先、Agent Host のログの場所を参照するときに使う。貼付画像を外部へ添付・コピー・OCR する前にも読む。保存先の SSOT として読み出すための手動参照メモ"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-10-18 -->

# VS Code 環境情報

VS Code 環境でよく参照する保存先と配置場所のメモ。「どこに何があるか」の SSOT として使う。

## ファイルパス

### チャット画像の保存先

- Agent Host のチャットに貼り付けた画像は、以下に保存される（2026-10-18 に実測）:
  - `%APPDATA%\Code\agentSessionData\<sessionId>\attachments\<guid>\`
- 旧 Local harness の貼付画像は `%APPDATA%\Code\User\workspaceStorage\vscode-chat-images\`（`image-{timestamp}.png`）にあった。Agent Host では、まず添付として提示されたパスを使い、見つからないときだけここを確認する
- チャットで画像を参照・取り込むときは、添付時刻に近いファイルを候補にする。候補が複数なら寸法や画像内容で照合する。Screenpresso は、ユーザーが同ツールで撮影したと示した場合、または一致候補がない場合だけ確認する。
- 必要に応じて、ワークスペース内に用途に合ったファイル名でコピーして使用してよい

### 個人の Copilot 資産

- instructions / skills / agents は `$HOME\.copilot\` 配下に置く（`%APPDATA%\Code\User\prompts\` は使わない）
- ワークスペース固有のものは各リポの `.github/` 配下（instructions / agents / skills）に置く

### Agent Host のログとセッション

- Agent Host のログ: `%APPDATA%\Code\logs\<日時>\agenthost.log`（MCP の接続状態、モデル一覧、tool 実行が記録される）
- Copilot のセッション状態: `$HOME\.copilot\session-state\<sessionId>\`
- 旧 Local harness の debug log は `%APPDATA%\Code\User\workspaceStorage\<workspace-hash>\GitHub.copilot-chat\debug-logs\<sessionId>\`（`main.jsonl`、`models.json`）にあり、Agent Host のセッションには作られない

## 拡張機能ストレージ

- `%APPDATA%\Code\User\globalStorage\` — グローバル拡張機能データ
- `%APPDATA%\Code\User\workspaceStorage\` — ワークスペース別データ

## Notes

- GitHub CLI 認証トラブル、PowerShell 運用、Web 検索 fallback の詳細は扱わない。
- ログの読み方や silent stop の切り分け手順も扱わない。ここは保存先だけを持つ。
