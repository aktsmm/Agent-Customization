---
description: エージェント定義とinstructionファイルのレビュー
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Review Agents & Instructions

エージェント定義（`.agent.md`）と指示ファイル（`.instructions.md` / `.prompt.md`）をレビューし、構造・SSOT・整合性の問題を検出する。

## Context Gate

対象（存在する場合）:

- `AGENTS.md` / `CLAUDE.md` / `CODEX.md`（いずれか1つ優先）
- `.github/copilot-instructions.md`
- `.github/agents/*.agent.md`
- `.github/instructions/**/*.md`
- `.github/prompts/*.prompt.md`

Gate:

1. `AGENTS.md` / `CLAUDE.md` / `CODEX.md` があれば通常レビュー
2. それらが無くても `.github/instructions/` に `.instructions.md` があれば instructions 中心で続行
3. `.github/instructions/` も空なら、ワークスペースの目的・構造・言語・主要ツールを見て最小限の設計資産を提案または生成してからレビュー

## Quick Check（必須）

1. SRP: 1 agent = 1責務
2. Fail Fast: 初期ステップで検証
3. 委譲: Orchestrator が実装作業を抱え込まない
4. SSOT: 重複定義がない
5. Done Criteria: 完了条件が検証可能
6. 統合候補: 単独参照 sub-agent がないか
7. 過剰分割: 小さすぎる agent の乱立
8. God Agent: 1ファイル過大化 + 複数責務

## Review Flow

1. Context Gate を通す
2. Quick Check 8項目を評価する
3. Cross-reference と prompt 重複を確認する
4. 統合すべきもの / 分割すべきものを判定する
5. 優先度順に返す

## 追加チェック

- Cross-reference: AGENTS と各 agent/instructions の記述整合
- Prompt 重複: 役割が重複する prompt/instructions の統合余地
- Architecture: 統合すべきもの / 分割すべきものの判定

## 優先度

- 🔴 Critical: 依存破損、Cross-reference 破綻
- 🟠 High: SSOT違反、God Agent、I/O 不明瞭
- 🟡 Medium: 冗長・統合余地・回復性不足
- 🟢 Low: 文体・軽微な整形

## Completion Criteria

- Context 読み込み完了
- Quick Check 8項目評価完了
- Cross-reference 検証完了
- 出力フォーマット準拠

## Output Format

### ✅ Good Points
- {良い点}

### ⚠️ Improvements Needed
- {優先度} {カテゴリ}: {file}:{line} → {解決策}

### Recommendation
- {総合評価と次アクション}
