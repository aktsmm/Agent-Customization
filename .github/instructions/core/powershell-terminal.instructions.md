---
description: "PowerShell ターミナル操作規約（PowerShell 互換、破壊的操作の注意、task と terminal の使い分け）"
applyTo: "**"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-06-14 -->

# PowerShell Terminal Instructions

エージェントが PowerShell ターミナルを使うときの最小ルールです。

## 1. 実行前チェック

- 最初に `Get-Location` で現在地を確認する。
- 想定ディレクトリと違う場合は `Set-Location` で移動し、複数リポジトリ環境では対象 repo であることを確認する。
- ファイル操作前は `Test-Path` などで対象の存在を確認する。

## 2. PowerShell 構文を使う

- コマンドは PowerShell 互換で書く（Bash 構文を混ぜない）。
- Bash heredoc (`<<EOF` / `<<'PATCH'`) や patch 本文を terminal に送らず、ファイル編集ツールか短い単発コマンドを使う。
- 連結は `;`（`&&` は使わない）、出力破棄は `$null`（`/dev/null` は使わない）を使う。
- 文字列・変数展開・パイプラインは PowerShell の流儀に合わせる。
- `foreach (...) { ... } | Format-Table` のように statement form 直後へ pipe しない。結果を変数に受けてから pipe するか、pipeline-native な `ForEach-Object` を使う（`An empty pipe element is not allowed` 回避）。
- `python -c "..."` に複数行コードを埋め込まない。1行で済まなければスクリプトファイルと編集ツールを使う。

## 3. 安全運用

- 削除や移動などの破壊的操作は、対象パスを明示して実行する。
- ワイルドカード削除は最小限にする。repo ルートの `Remove-Item *.json` / `*.txt` は tracked file を巻き込むため、一時ファイルは `tmp/` 配下か明示名で削除する。
- ブラウザの user data / profile directory を削除する前に、それが既定プロファイルか、一時 `--user-data-dir` かを確認する。既定プロファイル削除は通常禁止し、一時プロファイルだけを対象にする。
- `git reset --hard` など不可逆操作の前に、変更確定またはバックアップを行う。

## 4. 長時間プロセス

- サーバー・watch・監視処理はバックグラウンド実行を優先する。
- 長時間実行時は、ユーザーへ意図と停止方法を簡潔に伝える。

## 4.5 Task vs Terminal

- 単発の調査、デバッグ、認証依存、環境変数依存、出力追跡が必要な実行は terminal を優先する。
- task は、再利用する stable entry point、watch、background job、problem matcher が必要な実行に限る。
- 同じ単発実行が 2 回以上発生したら script / CLI への昇格を検討し、task が必要なら既存の generic process task や input 付き task を優先する。
- `retry` `debug` `with fresh auth` のような派生 one-off task を常設しない。
- `.vscode/tasks.json` の `command` や `args` にはローカル絶対パスを直書きせず、ワークスペース配下は `${workspaceFolder}` を使う。例外は task `label` か近傍コメントで理由を残す。

## 5. 運用メモ

- 一時変数を使うコマンド（例: `gh issue comment --body`）は、変数定義と実行を同一ターミナル実行にまとめる。
- `gh` や類似 CLI で `--json number,title,url` のようなカンマ区切り引数や、空白を含む検索式を渡すときは、PowerShell で必ず 1 つの文字列として引用する。分解されると別引数扱いになり、検索失敗や `accepts 1 arg(s)` 系エラーになりやすい。
- 日本語を含むファイルや JSON を扱うときは UTF-8 を維持する。
- スクリプトや CLI を実行する前に、対象 script / 実行ファイルの存在を確認する。不在時は実行せず、read/grep などの代替検証へ切り替える。
- VS Code task は再利用する registry とし、日付入り・対象固定の one-off task を常設しない。一時 task と一時スクリプトは完了前に削除する。
- スクリプトや CLI の変更系操作は、既定を read-only / dry-run にし、破壊的変更や外部反映は `--apply` などの明示フラグを必須にする。
- 不要な async / timeout terminal は作業完了前に閉じ、共有 terminal は不要と断定できる場合だけ対象にする。残す場合は理由と停止方法を報告する。
- 低頻度の shell 復旧、credential、publish、CDP、Office ロックは、該当タスクで専用の手動参照 instruction を使う。