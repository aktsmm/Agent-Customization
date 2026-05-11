---
description: "エージェント定義と instruction / prompt ファイルを横断的にレビューし、SSOT・整合性・構造の問題を検出する包括レビュー用"
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
- 使わない: 単一ファイルの本文を圧縮・整理するだけのとき → `refactor-context` を使う

## Context Gate

対象（存在する場合）:

- `AGENTS.md` / `CLAUDE.md` / `CODEX.md`（いずれか1つ優先）
- `.github/copilot-instructions.md`
- `.github/agents/*.agent.md`
- `.github/instructions/**/*.md`
- `.github/prompts/*.prompt.md`（`all` / `徹底的` / 明示指定時のみ）
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

## Review Flow

1. Context Gate を通す
2. Quick Check 9項目を評価する
3. 標準チェックを必ず実施する
4. 標準チェックの結果を踏まえて統合 / 分割 / 新規作成 / 削除・パージ候補を判定する
5. 優先度順に返す

## 標準チェック（必須）

- Cross-reference: AGENTS と各 agent/instructions の記述整合
- Prompt 重複: 役割が重複する prompt/instructions の統合余地
- Architecture: 統合 / 分割 / 新規作成 / 削除・パージ候補の判定
- Efficiency: 同一 prompt 内の不要な重複操作、差分ベースで済むフル実行、1 コマンドに統合可能な連続操作
- Global Prompt DRY/SSOT: Global User Data 側の prompt や Agent は単体利用前提で、ファイル内で自己完結する DRY/SSOT が保てているか

## 優先度

- 🔴 Critical: 依存破損、Cross-reference 破綻
- 🟠 High: SSOT違反、God Agent、I/O 不明瞭
- 🟡 Medium: 冗長・統合余地・回復性不足
- 🟢 Low: 文体・軽微な整形

## Completion Criteria

- Context 読み込み完了
- Quick Check 9項目評価完了
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
