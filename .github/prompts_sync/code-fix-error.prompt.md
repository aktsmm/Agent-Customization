---
description: エラーを原因特定→最小修正→確認の流れで解決（確認/オート対応・非対話検証優先）
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Fix Error

エラーを分析し、原因特定→最小修正→確認まで実行する。

## 実行状態契約（次回引き継ぎ）

- 状態ブロック（既定）: `.github/review-learnings.md` 内の `prompt-state:code-fix-error`
- ダッシュボード: `DASHBOARD.md`（なければ作成）


## モード（確認 / オート）

- `自動` / `オート` / `auto` を含む: オート（追加確認なし）
- それ以外: 確認（適用直前に1回確認）

## 出力フォーマット（PDCA）

1. **Cause**（原因）
2. **Do**（最小修正: 方針 + 変更ファイル）
3. **Check**（実施チェックと結果。不可なら理由と代替手順）
4. **Not Done**（なければ `なし`）
5. **Act**
   - **確認**（最大2件、`~3d/~7d/~30d`）
   - **新観点**（最大2件、原則1件以上。無ければ `なし`）
     - 前回 Carry Over の `Next Steps` と同一観点のみで埋めない（最低1件は別軸）
     - 同一観点を継続する場合は `（継続理由: {未解消リスク}）` を末尾に付ける
6. **再発防止**（1件）

## エラー情報

```
（エラーメッセージを貼り付け）
```

## 追加コンテキスト（推奨）

| 項目 | 内容 |
| --- | --- |
| ファイルパス | |
| 実行コマンド | |
| 環境 | |
| 期待する挙動 | |
| 再現手順 | |

## 指示

0. 実行開始時に `.github/review-learnings.md` の `prompt-state:code-fix-error` ブロックを読む（無い場合は初回として続行）
   - 前回 `Not Done` / `Next Steps` は優先観点として扱う
   - ただし `Act > 新観点` には、前回 Carry Over と異なる観点を最低1件含める
1. **コンテキスト収集**（存在する場合のみ）
   - `.github/copilot-instructions.md`（必須）
   - `AGENTS.md`（Learnings があれば参照）
   - `.github/review-learnings.md` の `Session Log` / `Next Steps`
2. 情報不足時
   - オート: `grep_search` / `read_file` / `get_errors` で自力調査
   - 確認: 追加質問は最大3つ
3. 最小差分で修正（同種パターンは必要範囲で同時修正）
4. 可能なら IDE/言語サーバ診断で確認（例: `get_errors`）
5. 既定では `run_task` を使わない（ターミナルの「任意キーで閉じる」待機回避）
6. `execute/runInTerminal` は必要に応じて使用してよい（非対話・単発・timeout 指定のコマンドに限定する）
7. `watch` / `dev` / 常駐サーバー起動 / 入力待機が発生するコマンドは実行しない
8. 再発防止ヒントを1つ提示

> **Check 原則**: 既存手順（scripts / CI / README）を優先。無い場合のみ最小チェック。
> 例: Python は `.venv` 優先で `-m py_compile <変更ファイル>`。

## 品質チェック

### 推奨: Developer / Reviewer 分離（最大3回）

- Developer: 最小修正 + 検証結果を記録
- Reviewer: 未解消・回帰・修正漏れを判定（PASS / NEEDS_FIX）
- NEEDS_FIX 時は再修正、3回失敗で停止
- 保存先は `.github/temp/` → `.temp/` → チャット の順

### 簡易レビュー（最大2回）

- `runSubagent` で最小性/妥当性/見落としを確認
- 不可時は自己レビュー1回

## Learnings 蓄積

### 出力先

| 条件 | 出力先 |
| --- | --- |
| デフォルト | `.github/review-learnings.md` |
| 「ワークスペース」「ローカル」指定 | `{workspace}/review-learnings.md` |
| パス指定あり | 指定パス |
| ファイルなし | フォーマットに従い新規作成 |

### ルール

- 再利用できる知見のみ記録（重複禁止）
- `## Session Log` / `## Next Steps` の共通欄は自動上書きしない
- 代わりに `prompt-state:code-fix-error` ブロックのみ毎回上書きする
- 各項目に `~3d` / `~7d` / `~30d` を付与

## Prompt Session Block（必須）

最終出力の末尾に、`.github/review-learnings.md` の自分用ブロックへ上書きする内容を必ず付ける。

```markdown
<!-- START:prompt-state:code-fix-error -->
## Prompt Session State: code-fix-error

### Run Meta
- runId: <YYYYMMDD-HHmmss>
- status: success|partial|failed
- startedAt: <ISO8601>
- endedAt: <ISO8601>
- nextRunHint: 15m|30m

### Carry Over（次回優先）
- Not Done:
   - なし
- Next Steps:
   - [ ] <確認または新観点> `~7d`

### Todo Queue
- [ ] <次回の実行タスク>

### Learnings Delta
- なし
   - ある場合のみ、今回新規で得た学びを1〜3件
<!-- END:prompt-state:code-fix-error -->
```

## State / Dashboard 更新（必須）

1. 実行開始時に `.github/review-learnings.md` の `prompt-state:code-fix-error` を読み込む（読めない場合は `status=partial` 理由を残して続行）
2. 実行終了時に `prompt-state:code-fix-error` ブロックのみ上書き保存する
3. ダッシュボードに `workflowId / status / endedAt / nextRunHint / nextStepsCount` を反映する

## Constraints

- `run_task` は使用しない（入力待機メッセージ回避）
- `execute/runInTerminal` は利用可。非対話・単発・timeout 必須

### 最小フォーマット

```markdown
# Review Learnings

## Universal（汎用 — 他プロジェクトでも使える）
### U1: <タイトル>
- **Tags**: `<観点>` `<観点>`
- **Added**: YYYY-MM-DD
- **Evidence**: <事象>
- **Action**: <対策>

## Project-specific（このワークスペース固有）
### P1: <タイトル>
- **Tags**: `<観点>` `<観点>`
- **Added**: YYYY-MM-DD
- **Evidence**: <事象>
- **Action**: <対策>

## Session Log
<!-- YYYY-MM-DD -->
### Done
- {修正の要点}
### Not Done
- {スキップ項目}: {理由}

## Next Steps
### 確認（今回の修正が効いているか）
- [ ] {修正X}: {期待する結果} `~{Nd}`
### 新観点（今回カバーできなかった品質改善）
- [ ] {観点}: {具体タスク} `~{Nd}`
```
