---
description: "PowerShell ターミナル操作規約（PowerShell 互換、破壊的操作の注意、task と terminal の使い分け）"
applyTo: "**"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-06-14 -->

# PowerShell Terminal Instructions

エージェントが PowerShell ターミナルを使うときの最小ルールです。

## 1. 実行前チェック

- 最初に `Get-Location` で現在地を確認する。
- 想定ディレクトリと違う場合は `Set-Location` で移動してから実行する。
- 複数リポジトリ環境では、対象 repo であることを確認する。
- ファイル操作前は `Test-Path` などで対象の存在を確認する。

## 2. PowerShell 構文を使う

- コマンドは PowerShell 互換で書く（Bash 構文を混ぜない）。
- Bash heredoc (`<<EOF` / `<<'PATCH'`) や patch 本文を terminal に送らない。PowerShell ではリダイレクトとして崩れて `>>` 継続待ちに入りやすいため、ファイル編集ツールか短い単発コマンドへ切り替える。
- 連結は `;` を使う（`&&` は使わない）。
- 出力破棄は `/dev/null` ではなく `$null` を使う。
- 文字列・変数展開・パイプラインは PowerShell の流儀に合わせる。
- `python -c "..."` の複数行は禁止（here-string `>>` に入りターミナルが復帰不能になる）。1 行で済む簡易チェック以外は `.py` ファイルに書いて実行する。
- PowerShell `@"..."@` here-strings は `{...}` をサブ式として解釈する。Python f-string (`f"{var}"`)、JS テンプレートリテラル、regex `\d{1,2}` を含むソースの書き出しには使えない。複数行スクリプトの作成はファイル編集ツールを優先し、terminal 経由なら単一行の `[System.IO.File]::WriteAllBytes` + Base64（here-string で包まない）か、既存 `.py` を `replace_string_in_file` で編集する。

## 3. 安全運用

- 削除や移動などの破壊的操作は、対象パスを明示して実行する。
- ワイルドカード削除は最小限にし、広すぎる対象は避ける。
- ブラウザの user data / profile directory を削除する前に、それが既定プロファイルか、一時 `--user-data-dir` かを確認する。既定プロファイル削除は通常禁止し、一時プロファイルだけを対象にする。
- `git reset --hard` など不可逆操作の前に、変更確定またはバックアップを行う。

## 4. 長時間プロセス

- サーバー・watch・監視処理はバックグラウンド実行を優先する。
- 長時間実行時は、ユーザーへ意図と停止方法を簡潔に伝える。

## 4.5 Task vs Terminal

- 単発の調査、デバッグ、認証依存、環境変数依存、出力追跡が必要な実行は terminal を優先する。
- task は、再利用する stable entry point、watch、background job、problem matcher が必要な実行に限る。
- 同じ単発実行が 2 回以上発生したら、まず script / CLI に昇格し、task は wrapper が必要な場合だけ追加する。
- `retry` `debug` `with fresh auth` のような派生 one-off task を常設しない。

## 5. 運用メモ

- 一時変数を使うコマンド（例: `gh issue comment --body`）は、変数定義と実行を同一ターミナル実行にまとめる。
- `gh` や類似 CLI で `--json number,title,url` のようなカンマ区切り引数や、空白を含む検索式を渡すときは、PowerShell で必ず 1 つの文字列として引用する。分解されると別引数扱いになり、検索失敗や `accepts 1 arg(s)` 系エラーになりやすい。
- 日本語を含むファイルや JSON を扱うときは UTF-8 を維持する。
- スクリプトや CLI を実行する前に、対象 script / 実行ファイルの存在を確認する。不在時は実行せず、read/grep などの代替検証へ切り替える。
- VS Code task は再利用する task の registry として扱い、日付入り・対象固定の one-off task を常設しない。単発実行は terminal か一時 script を優先し、残すなら入力付きの generic task に寄せる。
- 一時 task を使った場合は、完了前に `.vscode/tasks.json` の一時 task と一時スクリプトを削除し、残った task terminal の扱いを最終報告に書く。
- スクリプトや CLI の変更系操作は、既定を read-only / dry-run にし、破壊的変更や外部反映は `--apply` などの明示フラグを必須にする。
- 不要になった async terminal や timeout 後に裏で残った terminal は作業完了前に閉じる。対象は自分がそのターンで起動した dedicated / ad hoc terminal を優先し、共有 `pwsh`・editor terminal・拡張機能管理の terminal は不要と断定できない限り閉じない。
- terminal を残す場合は、残す理由と停止方法を最終報告に明記する。
- 共有 shell が `>>` 継続待ちや引用崩れで不安定になったら、回復確認は 1 回までに留め、復旧しなければ clean shell、短い runner script、task、または one-shot `pwsh -NoProfile -Command` に切り替える。
- Windows 環境で高速な全文検索が必要な場合は、`Select-String` より `ripgrep` (`rg`) を優先してよい。
- `rg` 未導入なら `winget install --id BurntSushi.ripgrep.MSVC --scope user --accept-source-agreements --accept-package-agreements` で導入してよい。
- 長い quoted 引数列、複数行文字列、here-string、長文 Markdown/JSON/issue body など引用崩れしやすい内容は terminal に直打ちせず、runner script か `--body-file` のように一時ファイル経由で渡す。`>>` 継続待ちに入ると復旧より clean shell への切替の方が速い。
- 共有 shell に長い配列リテラル、複数行の `@(...)`、長い `Copy-Item` 群、複雑な `foreach` をそのまま流すと `>>` 継続待ちに入りやすい。複数ファイルを扱うときは、短い単発コマンドに分けるか、dry-run 既定の helper script に寄せる。
- 環境変数永続化や単発の OS 設定変更は、shared shell より one-shot `pwsh -NoProfile -Command` を優先してよい。
- 既存の VS Code terminal では User スコープ環境変数が現在の Process に未反映のことがある。`$env:` に無ければ未設定と断定せず、必要なら `[System.Environment]::GetEnvironmentVariable('<NAME>','User')` も確認する。
- `$env:$name` は構文エラーになる（`:` の後に変数参照は不可）。名前を変数で動的にアクセスするには `(Get-Item "Env:$name" -ErrorAction SilentlyContinue).Value` か `[System.Environment]::GetEnvironmentVariable($name, 'Process')` を使う。
- CLI が無出力で終了しても成功とみなさず、想定 artifact の存在・更新時刻・機械可読フィールドを確認する。stdout だけで完了判定しない。
- release / publish 前の gate（lint / test / build / package / publish）は、shared shell に長い `;` 連結で流さず、**dedicated terminal で 1 コマンドずつ**実行して失敗位置を明確にする。途中の 1 ステップだけ失敗しても後続出力に埋もれやすい。
- PowerShell script を編集した場合は、`[scriptblock]::Create((Get-Content -Raw -Encoding UTF8 <file>))` で構文確認してよい。
- 同じ browser / CDP / SaaS 管理画面を操作するコマンドは、競合を避けるため直列実行を優先する。

## 6. 詳細メモの逃がし先

- CDP、VS Code extension packaging、stale token、stdout capture などの低頻度ノウハウはここへ増やさず、必要時だけ手動参照メモとして扱う。