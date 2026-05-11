---
description: "ターミナル操作規約（PowerShell 互換、破壊的操作の注意）"
applyTo: "**"
---


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
- `python -c "..."` の複数行は禁止（here-string `>>` に入りターミナルが復帰不能になる）。1 行で済む簡易チェック以外は `.py` ファイルに書いて実行する。

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
- VS Code task は完了後も「ターミナルはタスクで再利用されます」と表示された task terminal を残すため、一回限りの監査・同期・検証では原則増やさない。必要で使った場合は、完了前に `.vscode/tasks.json` の一時 task と一時スクリプトを削除し、残った terminal / task の扱いを最終報告に書く。
- Windows 環境で高速な全文検索が必要な場合は、`Select-String` より `ripgrep` (`rg`) を優先してよい。
- `rg` 未導入なら `winget install --id BurntSushi.ripgrep.MSVC --scope user --accept-source-agreements --accept-package-agreements` で導入してよい。
- 導入直後のシェルで `rg` が見つからない場合は、ターミナル再起動か、`$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')` で PATH を再読込してよい。
- PowerShell で `rg` の日本語出力が文字化けする場合は、`[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)` と `$OutputEncoding = [Console]::OutputEncoding` を先に設定してよい。
- Python CLI の出力で `¥` などが `ﾂ･` 等に化けるときは、コンソール側 cp932 表示の問題でファイル本体は正常なケースが多い。デバッグでは `--json out.json` 等で出力ファイルを書き、別エディタで開いて検証する。Python 側は冒頭で `sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', line_buffering=True)` を入れて `UnicodeEncodeError` を防ぐ。
- 共有 `pwsh` が未終了 here-string、`>>`、prompt-only、継続入力待ちに落ちた場合、その terminal は**汚染済み**として扱う。`run_in_terminal` も同じ汚染セッションを再利用することがあるため、終端文字や追加コマンドで復旧を試み続けず、以後の検証・生成・永続化は VS Code task、clean shell、または事前作成済みスクリプトの単発実行へ切り替える。
- Brave などの Web 検索が同一タスク内で 3 回以上連続して失敗した場合は、Web 検索不能と決めつけず、`copilot -p "{クエリ}" --allow-all-tools --allow-all-urls --available-tools web_search --silent` をフォールバックとして使ってよい。
- URL 列挙が目的のときは、URL のみを 1 行 1 件で返すよう指示し、CLI 出力の前置き文は除去して扱う。
- instruction ファイルや設計資産内のコードブロックにも絶対パスを埋め込まない。`Set-Location` が必要な場合は「ワークスペースルートで実行する前提」とコメントで補足し、パスのハードコードは省く。
- deferred tool を呼ぶ前に `tool_search` でロード済みかを確認する。同一 tool で 2 回エラーが出たら即 `tool_search` に切り替える。
- `create_and_run_task` はターミナル ID を返さないため出力追跡に使えない。出力確認が必要な場合は `run_in_terminal` を使う。スクリプトファイルを先に作成して `run_in_terminal` で実行する方法も有効。
- `create_and_run_task` はワークスペース外パスの操作に原則使わない。やむを得ず一時 task から外部 repo を確認する場合は、`Set-Location` 依存ではなく `git -C <repo>` や対象 script の明示パスなど、コマンド自体に対象 repo を明示する。
- `+`、空白、括弧、長い quoted 引数列を含む PowerShell 実行は、共有 terminal に直打ちせず、短い runner script と引数配列で実行する（2026-05-11 / GitHub Copilot）。
- task / runner の stdout が Windows encoding で失敗しても、JSON artifact を生成する設計なら artifact の存在と内容を先に確認する。stdout は ASCII / UTF-8 か静音を優先する（2026-05-11 / GitHub Copilot）。
- `--output-json` や同等の JSON status artifact を返す長時間 runner は、stdout の見た目や終了メッセージより `final_status` `overall_status` `status` などの機械可読フィールドを正本として完了判定する。stdout は補助証跡として扱う（2026-05-11 / GitHub Copilot）。
- 一時 VS Code task を使った場合は、対象 label と一時 runner を削除し、最後に tasks JSON が parse できることを確認する（2026-05-11 / GitHub Copilot）。
