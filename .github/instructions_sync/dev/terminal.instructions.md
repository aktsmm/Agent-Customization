---
applyTo: "**"
---

<!-- description: ターミナル操作規約（PowerShell 互換、破壊的操作の注意） -->

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Terminal Command Execution Instructions

エージェントがターミナルを使うときの最小ルールです。

## 1. 実行前チェック

- 最初に `Get-Location` で現在地を確認する。
- 想定ディレクトリと違う場合は `Set-Location` で移動してから実行する。
- 複数リポジトリ環境では、対象 repo であることを確認する。
- ファイル操作前は `Test-Path` などで対象の存在を確認する。

## 2. PowerShell 構文を使う

- コマンドは PowerShell 互換で書く（Bash 構文を混ぜない）。
- 連結は `;` を使う（`&&` は使わない）。
- 出力破棄は `/dev/null` ではなく `$null` を使う。
- 文字列・変数展開・パイプラインは PowerShell の流儀に合わせる。

## 3. 安全運用

- 削除や移動などの破壊的操作は、対象パスを明示して実行する。
- ワイルドカード削除は最小限にし、広すぎる対象は避ける。
- `git reset --hard` など不可逆操作の前に、変更確定またはバックアップを行う。

## 4. 長時間プロセス

- サーバー・watch・監視処理はバックグラウンド実行を優先する。
- 長時間実行時は、ユーザーへ意図と停止方法を簡潔に伝える。

## 5. 運用メモ

- 一時変数を使うコマンド（例: `gh issue comment --body`）は、変数定義と実行を同一ターミナル実行にまとめる。
- 日本語を含むファイルや JSON を扱うときは UTF-8 を維持する。
