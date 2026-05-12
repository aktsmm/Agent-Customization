---
name: "review-agents-and-instructions"
description: "エージェント定義と instruction / prompt ファイルを横断的にレビューし、SSOT・整合性・構造の問題を検出する包括レビュー用"
argument-hint: "対象パス、review 観点、all / 徹底的 などの範囲指定"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# review agents and instructions

エージェント定義（`.agent.md`）と指示ファイル（`.instructions.md` / `.prompt.md`）をレビューし、構造・SSOT・整合性の問題を検出する。

## When to Use

- 使う: 複数の agent / instruction / prompt を横断して SSOT・整合性・構造をチェックしたいとき
- 使う: 統合候補・分割候補・依存破綻など包括的な再設計判断が必要なとき
- 使わない: 単一ファイルの本文を圧縮・整理するだけのとき

その場合は、この prompt でも扱える範囲だけ指摘してよいが、横断レビューそのものを前提にはしない。

## Reference Skill

ワークスペース内に `.github/skills/agentic-workflow-guide/` がある場合は、設計原則・チェック項目・anti-pattern の SSOT として **強く推奨**：

- `.github/skills/agentic-workflow-guide/SKILL.md`（Review Gates / Pattern Selection）
- `.github/skills/agentic-workflow-guide/references/review-checklist.md`（Quick Check / Deterministic Offload Check / 詳細チェック）
- `.github/skills/agentic-workflow-guide/references/design-principles.md`（原則の判定基準）

この prompt は入口だけを提供し、判定基準は SKILL 側を SSOT として参照する。
存在しない場合（私物 repo / 他 workspace 等）は、この prompt 単体のチェック項目だけで実施する。

## Context Gate

対象（存在する場合）:

- `AGENTS.md` / `CLAUDE.md` / `CODEX.md`（いずれか1つ優先）
- `.github/copilot-instructions.md`
- `.github/agents/**/*.agent.md`（直下以外は scan されない agent / template の誤配置検出用）
- `.github/instructions/**/*.md`
- `.github/prompts/*.prompt.md`（`all` / `徹底的` / 明示指定時のみ）
- `.github/skills/**/SKILL.md` は既定対象外。ユーザーが skill / SKILL.md / skill folder を明示した場合のみ、frontmatter と自己完結性をレビューする
- その他、現在セッションで自動ロードまたは明示参照されている instruction injection files（ただし Global を明示指定していない場合は `%APPDATA%/Code/User/prompts/` と `~/.copilot/` を除く）

既定は workspace（`.github`）中心でレビューする。`all` / `徹底的` 指定でも Global（User Data / `~/.copilot`）は対象に含めない。
ただし、Global を明示指定された場合は `%APPDATA%/Code/User/prompts/` と `c:\Users\vainf\.copilot\` の両方を対象に含めてよい。
上記のいずれかがあればレビューを続行する。
上記が無ければ、ワークスペースの目的・構造・言語・主要ツールを見て最小限の設計資産を提案または生成してからレビューする。

## Quick Check（必須）

1. SRP: 1 agent = 1責務
2. Fail Fast: 初期ステップで検証
3. 委譲: Orchestrator が実装作業を抱え込まない
4. SSOT: 重複定義がない
5. Done Criteria: 完了条件が検証可能
6. 統合候補: 単独参照 sub-agent がないか
7. 過剰分割: 小さすぎる agent の乱立
8. God Agent: 1ファイル過大化 + 複数責務
9. Efficiency: 不要ステップ・重複操作・差分で済むフル実行・1 コマンドに統合可能な連続操作がないか
10. Frontmatter: `.instructions.md` / `.prompt.md` / `.agent.md` の `description` / `applyTo` / `name` 等が用途に合うか、`applyTo` が過大でないか、glob クォートが統一されているかを確認する。`SKILL.md` は明示指定時のみ `name` / `description` / 自己完結性を確認する
11. Deterministic Offload: extract / count / validate / diff / format / parse / lint など決定論的に書ける処理が LLM / agent ループに紛れ込んでいないか。混じっていれば script / IR / hook へ逃がす（Reference Skill の `references/review-checklist.md` の Deterministic Offload Check を参照）

## Review Flow

1. Context Gate を通す
2. Quick Check 10項目を評価する
3. 標準チェックを必ず実施する
4. 標準チェックの結果を踏まえて統合 / 分割 / 新規作成 / 削除・パージ候補を判定する
5. 優先度順に返す

## 標準チェック（必須）

- Cross-reference: AGENTS と各 agent/instructions の記述整合
- Prompt 重複: 役割が重複する prompt/instructions の統合余地
- Architecture: 統合 / 分割 / 新規作成 / 削除・パージ候補の判定
- Efficiency: 同一 prompt 内の不要な重複操作、差分ベースで済むフル実行、1 コマンドに統合可能な連続操作
- Frontmatter Hygiene: `.instructions.md` / `.prompt.md` / `.agent.md` の `description` 欠落、必要な `applyTo` 欠落、過剰スコープ（手動参照用なのに `**`）、クォート不統一、`syncToGlobal` / 著者メタの欠落
- Agent Placement: `.github/agents/` 直下以外の `.agent.md` は VS Code scan 対象外。テンプレ用途なら `.md` 化または skill/reference へ集約し、参照元を更新する。未参照なら削除候補にする
- Skill Scope: `SKILL.md` は明示指定時のみ、`name` / `description` / `argument-hint` / `user-invocable` と、単体で使える自己完結性を確認する
- Global Prompt DRY/SSOT: Global User Data 側の prompt や Agent は単体利用前提で、ファイル内で自己完結する DRY/SSOT が保てているか

## 優先度

- 🔴 Critical: 依存破損、Cross-reference 破綻
- 🟠 High: SSOT違反、God Agent、I/O 不明瞭
- 🟡 Medium: 冗長・統合余地・回復性不足
- 🟢 Low: 文体・軽微な整形

## Completion Criteria

- Context 読み込み完了
- Quick Check 10項目評価完了
- 標準チェック実施完了
- Cross-reference 検証完了
- 出力フォーマット準拠

## Output Format

### ✅ Good Points
- {良い点}

### ⚠️ Improvements Needed
- {優先度} {カテゴリ}: {file}:{line} → {解決策}（Global/User Data 対象は `%APPDATA%/Code/User/prompts/<file>`、`~/.copilot/<path>` 形式も可）

### Recommendation
- {総合評価と次アクション}
