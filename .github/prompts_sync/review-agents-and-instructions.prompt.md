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

## Step 0: Context Collection

- 対象（存在する場合）
  - `AGENTS.md` / `CLAUDE.md` / `CODEX.md`（いずれか1つ必須）
  - `.github/copilot-instructions.md`
  - `.github/agents/*.agent.md`
  - `.github/instructions/**/*.md`
  - `.github/prompts/*.prompt.md`
- Gate: `AGENTS.md` / `CLAUDE.md` / `CODEX.md` がすべて無い場合:
  1. `.github/instructions/` 配下に `.instructions.md` ファイルが存在するか確認
  2. 存在する場合: instructions ファイルのみでレビューを続行（Quick Check の該当項目をスキップ）
  3. `.github/instructions/` も空 or 不在の場合:
     - ワークスペースの目的・構造・使用言語・主要ツールを分析
     - 以下の設計資産を生成して配置:
       - `AGENTS.md`（ワークスペースの概要・目的・主要ワークフロー）
       - `.github/copilot-instructions.md`（共通ルール）
       - `.github/instructions/` 配下にドメイン固有の `.instructions.md`
     - 生成後、Quick Check を実行してレビュー

## Quick Check（必須）

1. SRP: 1 agent = 1責務
2. Fail Fast: 初期ステップで検証
3. 委譲: Orchestrator が実装作業を抱え込まない
4. SSOT: 重複定義がない
5. Done Criteria: 完了条件が検証可能
6. 統合候補: 単独参照 sub-agent がないか
7. 過剰分割: 小さすぎる agent の乱立
8. God Agent: 1ファイル過大化 + 複数責務

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
