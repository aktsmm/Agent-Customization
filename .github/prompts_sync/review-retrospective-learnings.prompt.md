---
description: インシデントや会話から設計知見を抽出・反映
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Prompt: Retrospective Learnings

インシデント・会話から再利用可能な知見を抽出し、適切な設計資産へ反映する。

## 使用タイミング

- 使う: バグ解決後 / 再発発生時 / レビューで設計ギャップが見つかったとき
- 使わない: typo など軽微修正のみ / 環境固有問題のみ

## Phase 1: Context Collection

- 入力（1つ以上必須）
   - エラーログ、Git diff/commit、会話履歴、ターミナル履歴
- ターミナル観点
   - Exit Code ≠ 0
   - Ctrl+C（中断）
   - 同コマンド反復
   - 長時間実行
- Gate: 入力なしなら追加要求して停止

## Phase 2: Extract Learnings

- カテゴリ
   - 設計原則（SRP/SSOT/idempotency）
   - ワークフロー
   - プロンプト設計
   - コンテキスト設計
   - エラーパターン
- 1件ごとに `Learning / Evidence / Impact` を作成
- Gate: actionable な知見がなければ停止

## Phase 3: Decide Action & Target

- 優先度: Impact × Recurrence（P1/P2/P3）
- 反映先
   - 共通原則 → `AGENTS.md`
   - agent 固有 → `.github/agents/*.agent.md`
   - workflow ルール → `.github/instructions/**/*.md`
   - prompt パターン → `.github/prompts/*.prompt.md`
- 反映先ファイルが存在しない場合:
   - **停止しない。ファイルを新規作成して反映する**
   - ディレクトリも不在なら作成する
   - 作成後、Phase 4 の重複/矛盾チェックに進む

## Phase 4: Validate & Output

- Gate（全必須）
   - 重複ルールなし
   - 既存設計と矛盾なし
   - 各変更は最小差分
- 出力
   - `## Learnings`
   - `## Changes`
   - `## Review Checkpoint`

## Completion Criteria

- 全入力分析済み
- 優先度分類完了
- Gate 通過
- 設計資産へ実反映する場合のみユーザー承認済み

Stop: 知見なし / ユーザー拒否 / Gate 失敗

<!--
References:
- Anthropic Building Effective Agents: https://www.anthropic.com/engineering/building-effective-agents
- Anthropic Context Engineering: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
-->
