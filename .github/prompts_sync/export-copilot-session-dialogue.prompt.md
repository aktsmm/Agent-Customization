---
description: セッション中の対話フロー・使用ツール・成果を構造化出力（試行錯誤は回数のみ圧縮）
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Session Dialogue Export

セッションのプロンプト↔応答の流れ、使用ツール、成果を記録する。

## 出力先

- デフォルト: `D:\03.5_GHC_Research\_output-session-dialogue\`
- 上記が無ければ: `C:\03_GITHUB_output-session-dialogue\`
- `workspace` / `ローカル` 指定時: `{workspace}/_output-session-dialogue/`
- ファイル名: `YYYYMMDD-NN--{topic-slug}.md`（同日連番）

## 抽出項目

1. 目的（1文）と成果（1〜2文）
2. 使用モード（Ask/Edit/Agent/Plan）
3. 対話フロー（時系列）
4. 使用ツール（Agent/MCP/Instructions）
5. Handoffs / runSubagent
6. ワークフローパターン
7. 効果的だった技法
8. エラー・リトライ（型/原因/対処/回数）
9. 成果物と再利用知見

## 圧縮ルール

- ユーザー入力は「要約 + （原文）」で記録
- 試行錯誤は詳細コードを省略し、回数と理由だけ残す
- モード切替、handoff、runSubagent は明示的に残す

## 出力フォーマット

- `Session Overview`（目的/成果/モード）
- `Dialogue Flow`（フェーズ単位）
- `Tools Used`
- `Workflow & Techniques`
- `Deliverables`
- `Insights`
