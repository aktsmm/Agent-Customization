---
description: "PowerShell ターミナル操作規約（PowerShell 互換、破壊的操作の注意、task と terminal の使い分け）"
applyTo: "**"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-10-12 -->

# PowerShell Terminal Instructions

## 1. 実行前チェック

- 最初に `Get-Location` で現在地を確認する。
- 想定ディレクトリと違う場合は `Set-Location` で移動し、複数リポジトリ環境では対象 repo であることを確認する。
- ファイル操作・script / CLI 実行前は `Test-Path` などで対象の存在を確認する。script / 実行ファイルが不在なら実行せず、read/grep などの代替検証へ切り替える。

## 2. PowerShell 構文を使う

- コマンドは PowerShell 互換で書く（Bash 構文を混ぜない）。
- Bash heredoc (`<<EOF` / `<<'PATCH'`) や patch 本文を terminal に送らず、ファイル編集ツールか短い単発コマンドを使う。
- 連結は `;`（`&&` は使わない）、出力破棄は `$null`（`/dev/null` は使わない）を使う。
- 検証対象の native command を `;` で連結するときは、各実行直後に `$LASTEXITCODE` を確認するか、単発実行に分ける。前の失敗でも後続が実行され、最後の成功が結果を上書きするため。
- `foreach (...) { ... } | Format-Table` のように statement form 直後へ pipe しない。結果を変数に受けてから pipe するか、pipeline-native な `ForEach-Object` を使う（`An empty pipe element is not allowed` 回避）。
- `python -c "..."` に複数行コードを埋め込まない。1行で済まなければスクリプトファイルと編集ツールを使う。
- regex（例: `(?<!...)`）、f-string の `{}`、`|` を含む Python コードは1行でも `-c` に渡さない。PowerShellが先に解釈して失敗するため、一時スクリプトで実行し、完了後に削除する。

## 3. 安全運用

- 削除や移動などの破壊的操作は、対象パスを明示して実行する。
- 並行 writer がいる場所のファイル退避は copy→検証→削除にせず、同一ボリューム内の rename で移す（検証後〜削除前の更新を失わない）。移動後に hash と元位置への再作成を確認する。
- ワイルドカード削除は最小限にし、一時ファイルは明示名で削除する。repo ルートや `tmp/` の glob は tracked file や他作業のファイル・フォルダを巻き込む。
- ブラウザの user data / profile directory を削除する前に、それが既定プロファイルか、一時 `--user-data-dir` かを確認する。既定プロファイル削除は通常禁止し、一時プロファイルだけを対象にする。
- CDP で既存ブラウザを再利用する前に、debug port と親プロセスを確認する。debug port なしの既存プロセスに `--remote-debugging-port` を追加しても、起動は既存プロセスに合流し port が開かないことがある。
- 既存ブラウザの終了が必要な CDP 復旧は明示承認なしに行わず、port を開けない場合は同じ起動を反復せず、失敗理由と再開条件を記録する。
- `git reset --hard` など不可逆操作の前に、変更確定またはバックアップを行う。

## 4. 長時間プロセス

- サーバー・watch・監視処理はバックグラウンド実行を優先する。
- 長時間実行時は、ユーザーへ意図と停止方法を簡潔に伝える。
- 数十分以上かかる本体処理を chat terminal で起動しない。chat terminal は会話の進行で回収され、プロセスツリーごと落ちる。既存の適切な task など session 外の起動口を優先し、進捗は artifact（ログ、summary JSON、プロセス生存）から取得する。
- 無人実行（Scheduler 等）の prompt では、数秒以上無出力になるコマンドの stdout で分岐させない。sync 実行は無出力のまま先に返るため、結果ファイルを書かせ、記録時刻が今回の実行開始後であることを確認して読む。

## 4.5 Task vs Terminal

- 単発の調査・検証、デバッグ、認証・環境変数依存、出力追跡や terminal 出力取得の復旧は terminal を優先し、新規 task 作成を既定にしない。
- 同じ terminal への呼び出しは直列化する。コマンドの目的が独立していても shell は共有され得るため、並列化は実行環境が独立していると確認できる場合だけ行う。
- task は、再利用する stable entry point、watch、background job、problem matcher が必要な実行に限る。
- 同じ単発実行が2回以上なら script / CLI 化を検討する。task が必要なら既存の generic process task / input 付き task を優先する。
- 既存 task も必要な input 値・承認を確認し、対話不要と一括断定しない。無人で対話入力・承認が必要なら停止する。
- 新規 task 作成は、再利用入口の整備、ユーザーの明示依頼、または適用される安全契約で必要な場合に限る。
- 新規 task 作成ツールは手動承認を前提とし、無人の承認不要な復旧に使わない。別ツールで同じ登録を行う承認回避も禁止する。
- `retry` `debug` `with fresh auth` や日付入り・対象固定の派生 one-off task を常設しない。必要になった一時 task と一時スクリプトは、自分が作成したものだけを完了前に削除する。
- task label では判断せず、起動前に `command` / `args`・所有対象を確認する。対象未限定の queue / runner は他セッションの作業を消費するものとみなす。他セッションの作業を実行・削除せず、対象限定 task を共有 queue に置き換えない。
- `.vscode/tasks.json` の `command` や `args` にはローカル絶対パスを直書きせず、ワークスペース配下は `${workspaceFolder}` を使う。例外は task `label` か近傍コメントで理由を残す。

## 5. 運用メモ

- 一時変数を使うコマンド（例: `gh issue comment --body`）は、変数定義と実行を同一ターミナル実行にまとめる。
- `gh` 等の空白を含む検索式と `--json a,b,c` は、分解を防ぐため1つの文字列として引用する。`--jq` はシングルクォートで囲み、`$j` 等の変数をPowerShellに展開させない。
- `{}` を含む引数はPowerShellの解釈を防ぐためシングルクォートで囲む。Git の reflog / upstream も対象（例: `git rev-list --left-right --count 'HEAD...@{upstream}'`）。
- PowerShell の二重引用符内で `\"` はエスケープにならず文字列が途中で切れ、`>>` 継続待ちで止まる。`rg` などへ渡す regex は単一引用符で囲む。また `dir/*.py` はネイティブコマンドへ展開されず `rg` が os error 123 で落ちるため、`rg <pattern> dir -g '*.py'` を使う。
- 日本語を含むファイルや JSON を扱うときは UTF-8 を維持する。terminal 表示が化けるときは、`$env:PYTHONUTF8='1'` を設定し、`cmd /c "... > file"` で UTF-8 のままファイルへ出して `read_file` や `Get-Content -Encoding UTF8` で読む。
- `Get-Content -Raw` は CRLF を保持する。multiline regex で行末を照合するときは改行前の `\r` を許容するか、`\r?\n` で split する。
- スクリプトや CLI の変更系操作は、既定を read-only / dry-run にし、破壊的変更や外部反映は `--apply` などの明示フラグを必須にする。
- 不要な async / timeout terminal は作業完了前に閉じ、共有 terminal は不要と断定できる場合だけ対象にする。残す場合は理由と停止方法を報告する。
- 低頻度の shell 復旧、credential、publish、CDP、Office ロックは、該当タスクで専用の手動参照 instruction を使う。