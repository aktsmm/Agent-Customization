---
description: "セッション中の「対話フロー・使用ツール・手順」を構造化して出力"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# export copilot session dialogue

セッションのプロンプト↔応答の流れ、使用ツール、成果を記録する。

## Core Contract

- 対話フロー、使用ツール、handoff、成果、再利用知見を記録する
- 試行錯誤は詳細ではなく回数と理由に圧縮する
- モード切替と runSubagent / handoff は明示的に残す

## 出力先

- デフォルト: `D:\03.5_GHC_Research\_output-session-dialogue\`
- 上記が無ければ: `C:\03_GITHUB_output-session-dialogue\`
- `workspace` / `ローカル` 指定時: `{workspace}/_output-session-dialogue/`
- ファイル名: `YYYYMMDD-NN--{topic-slug}.md`（同日連番）

## Extraction Checklist

1. 目的（1文）と成果（1〜2文）
2. 使用モード（Ask/Edit/Agent/Plan）
3. 対話フロー（時系列）
4. 使用ツール（Agent/MCP/Instructions）
5. Handoffs / runSubagent
6. ワークフローパターン
7. 効果的だった技法
8. エラー・リトライ（型/原因/対処/回数）
9. 成果物と再利用知見

## Compression Rules

- ユーザー入力は「要約 + （原文）」で記録
- 試行錯誤は詳細コードを省略し、回数と理由だけ残す
- モード切替、handoff、runSubagent は明示的に残す

## Output Format

- `Session Overview`（目的/成果/モード）
- `Dialogue Flow`（フェーズ単位）
- `Tools Used`
- `Workflow & Techniques`
- `Deliverables`
- `Insights`
