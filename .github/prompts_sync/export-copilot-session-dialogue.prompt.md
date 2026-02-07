---
description: セッション中の対話フロー・使用ツール・成果を構造化出力（試行錯誤は回数のみ圧縮）
---

<!-- syncToGlobal: true -->

# Session Dialogue Export

セッションのプロンプト↔応答の流れ、使用ツール、成果を記録する。

## 出力先

| 条件                        | 出力先                                           |
| --------------------------- | ------------------------------------------------ |
| デフォルト                  | `D:\03.5_GHC_Research\_output-session-dialogue\` |
| 「workspace」「ローカル」等 | `{workspace}/output_sessions/`                   |
| パス指定あり                | 指定パス                                         |

- ファイル名: `YYYYMMDD--{topic-slug}.md`
- `Get-Date -Format "yyyy-MM-ddTHH:mm:ss"` でタイムスタンプ取得

## 抽出項目

1. セッション目的（1文）・最終成果（1-2文）
2. 使用モード: Ask / Edit / Agent / Plan
3. 対話フロー（時系列）
4. 使用ツール: エージェント / MCP / Instructions
5. Handoffs / runSubagent 呼び出し
6. ワークフローパターン（Prompt Chaining / Routing / Parallelization / Orchestrator-Workers / Evaluator-Optimizer / なし）
7. 効果的だったプロンプト技法
8. エラー・リトライ（型/原因/対処）
9. スキル参照

## 対話フロー圧縮ルール

| パターン      | 圧縮方法                                                  |
| ------------- | --------------------------------------------------------- |
| 成功した単発  | `[User] 要約 (原文) → [Copilot] 結果`                     |
| 試行錯誤あり  | `[User] 要約 (原文) → (N回試行) → [成功] 最終結果`        |
| 失敗→方針転換 | `[User] 要約 (原文) → [失敗: 理由] → [方針転換] → [成功]` |
| モード切替    | `[Mode: Ask → Agent]`                                     |
| Handoff       | `[Handoff: A → B] 理由`                                   |
| runSubagent   | `[runSubagent: 名前] タスク → 結果`                       |

- ユーザープロンプトは「要約 + (原文)」で記録
- 試行錯誤の詳細コードは省略、回数と理由のみ

## 出力テンプレート

```markdown
---
title: "{タイトル}"
datetime: YYYY-MM-DDTHH:mm:ss
duration: "{概算時間}"
tags: [{ タグ }]
---

## Session Overview

| 項目   | 内容     |
| ------ | -------- |
| 目的   | {目的}   |
| 成果   | {成果}   |
| モード | {モード} |

## Dialogue Flow

### 1. {フェーズ名}

- **[User]**: {要約} (`{原文}`)
- **[Copilot]**: {応答}
- **結果**: {成功/失敗}

## Tools Used

- **Agents**: {名前: 用途}
- **MCP**: {名前: 用途}
- **Instructions**: {パス: 適用内容}
- **Handoffs/Subagent**: {種別: 元→先, 目的, 結果}（なければ「なし」）

## Workflow & Techniques

- **パターン**: {名前 or なし}
- **効果的な技法**: {技法: 理由}
- **エラー**: {型, 原因, 対処, 試行回数}（なければ「なし」）
- **スキル参照**: {名前: 役立った点}（なければ「なし」）

## Deliverables

| ファイル | 種別      | 説明   |
| -------- | --------- | ------ |
| {パス}   | 新規/編集 | {内容} |

## Insights

- **再利用可能な知見**: {パターン}
- **改善点**: {次回への申し送り}
```
