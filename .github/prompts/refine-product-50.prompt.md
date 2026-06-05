---
name: "Refine Product 50"
description: "日常コードレビュー向け軽量リファインプロンプト。Use when: refine product 50, code review, レビュー, 軽量修正。プロジェクトルールと任意の Learnings を参照し、既定では確認ゲート後のユーザー承認に基づいて最小修正・同根 Sweep・検証まで行う"
argument-hint: "対象ファイル/差分/PR、重点観点、モード（plan only / review only / confirm / auto）"
agent: "agent"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

<!-- pattern: Lightweight evaluator-optimizer (review -> gate -> fix -> sweep -> verify) -->

# refine product 50

日常コードレビュー向けの軽量リファインプロンプト。対象コードをレビューし、必要な場合だけ最小修正、同根 Sweep、検証まで 1 サイクルで閉じる。

`refine-product-100` はリリース前・本格 QA・プロダクト全体改善に使う。この prompt はコードレビューの範囲を広げすぎない。

## Inputs / Modes

- Target: ファイル、差分、PR、フォルダ、現在の変更など
- Focus: バグ / 品質 / 設計 / セキュリティ / UI/UX / 性能 / test など。空欄は全般
- Mode: `plan only` / `review only` / `confirm` / `auto`。空欄は `confirm`

| Mode | 動作 |
| --- | --- |
| `plan only` | 調査計画だけ出す。編集しない |
| `review only` | 指摘だけ出す。編集しない |
| `confirm` | 指摘後に GATE を出し、承認された項目だけ修正する |
| `auto` / `自動` / `オート` | GATE を省略し、安全な `Fix now` を修正する |

## Principles

- 1 回のレビューで、見つけた問題を `Fix now` / `Guard now` / `Block` に分類する。
- `Fix now` は、依頼範囲内・非破壊・ローカル検証可能・正しさを説明できるものだけ。
- `Guard now` は、本修正は難しいがテスト、静的ガード、docs、確認手順でリスクを下げられるもの。
- `Block` は、破壊的操作、外部公開、仕様判断、secret、本番データ、権限不足が絡むもの。
- `confirm` では GATE 以外で不要に質問しない。`auto` でも `Block` は実行しない。
- Release、publish、version sync、配布物 hygiene は扱わない。必要なら `refine-product-100` に切り替える。

## Workflow

```text
Context -> Review -> GATE -> Fix -> Sweep -> Verify -> Report
```

### 1. Context

1. プロジェクト instruction / `AGENTS.md` / README / package scripts など、対象に効くルールだけ読む。
2. 対象コードと直接依存を読む。広い場合は差分、entry point、呼び出し元、テストを優先する。
3. `.github/review-learnings.md` があれば参考にする。ただし自動更新しない。

小規模なら対象全体を読む。大規模なら `grep_search` / `list_code_usages` / 差分確認で範囲を絞る。

### 2. Review

以下の観点で、重要度順に指摘する。

| 観点 | 見るもの |
| --- | --- |
| バグ | 例外、境界値、競合、リーク、状態不整合 |
| 品質 | DRY、命名、可読性、型、不要な複雑さ |
| 設計 | 責務分離、依存方向、一貫性、拡張時の破綻 |
| 外部連携 | SDK/API 使用、リトライ、認証、レート制限 |
| UI/UX | 文言、導線、ログ、エラー表示、回復導線 |
| 非機能 | セキュリティ、性能、回復性、観測性 |
| Learnings 適合 | 過去教訓の再発有無 |

出力形式:

| # | Marker | 観点 | ファイル:行 | 問題 | 分類 | 対応案 |
| --- | --- | --- | --- | --- | --- | --- |

Marker は `🔴 Critical` / `🟡 Important` / `🟢 Suggestion` を使う。

### 3. GATE

`confirm` のみ実施する。

| 入力 | 動作 |
| --- | --- |
| `all fix` | `Fix now` を全て修正 |
| `1,3,5` | 指定番号のみ修正 |
| `guard` | `Guard now` の代替だけ実施 |
| `review only` | 編集せず終了 |

`plan only` / `review only` ではここで終了する。

### 4. Fix

- 最小差分で修正する。
- 既存設計、命名、テストパターンに合わせる。
- 無関係リファクタ、仕様変更、公開操作、履歴改変はしない。
- `Guard now` はテスト、静的チェック、docs、確認手順のいずれか 1 つ以上を成果物にする。

### 5. Sweep

修正した観点について、同根問題だけ横展開する。

- 文字列、関数名、型、エラー文、設定キーなどで検索する。
- 同じ原因で安全に直せる箇所は一緒に直す。
- 概念的に近いだけの改善や別軸の品質改善は Next Steps に回す。

### 6. Verify

優先順:

1. エディタ診断 / `get_errors`
2. 既存 scripts / CI と同じ lint、typecheck、unit test
3. 対象に近い最小テスト
4. 不明時はスキップ理由を明記

`run_task` は使わない。ターミナルは非対話・単発・timeout 付きで実行する。`watch` / `dev` / 常駐サーバー / 入力待ちは起動しない。

失敗した場合は原因を読み、同一原因につき最大 2 サイクルまで修正と再検証を行う。それ以上は `Block` として残す。

## Final Response Format

```markdown
## Done
- {レビュー結果または修正内容}

## Findings
| # | Marker | 観点 | ファイル:行 | 問題 | 分類 | 対応 |
| --- | --- | --- | --- | --- | --- | --- |

## Sweep
- {同根確認。なければ「なし」}

## Check
- `{コマンドまたは確認方法}`: PASS / FAIL / SKIP（理由）

## Not Done / Next Steps
- {Guard now / Block / スコープ外だけ。なければ「なし」}

## Learnings Candidate
- {永続化したい学び候補。なければ「なし」}
```

`Learnings Candidate` は候補提示だけにする。`.github/review-learnings.md` や instruction へ反映するのは、ユーザーが明示した場合だけ。

## Stop Conditions

- `plan only` / `review only` 指定。
- `confirm` の GATE で終了が選ばれた。
- 対象 `Fix now` の修正、Sweep、検証が完了した。
- `Block` があり、非破壊の Guard も追加できない。
- 同一原因の再試行が 2 サイクルを超えた。

## Self-Check

- レビュー対象と依頼範囲を広げすぎていない。
- `Fix now` / `Guard now` / `Block` の分類がある。
- 修正した観点の Sweep を行った。
- 検証結果またはスキップ理由が具体的。
- release / publish / dashboard / state 更新を始めていない。
- 学びは候補提示に留め、永続化していない。
