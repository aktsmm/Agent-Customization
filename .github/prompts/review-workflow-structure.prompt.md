---
name: "review-workflow-structure"
description: "ワークフロー設計資産としての agent / instruction / prompt / AGENTS を横断レビューし、SSOT・整合性・構造の問題を検出する"
argument-hint: "対象パス、review 観点、all / 徹底的 などの範囲指定"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# review workflow structure

エージェント定義（`.agent.md`）と指示ファイル（`.instructions.md` / `.prompt.md`）をワークフロー設計資産としてレビューし、構造・SSOT・整合性の問題を検出する。

## When to Use

- 使う: 複数の agent / instruction / prompt を横断して SSOT・整合性・構造をチェックしたいとき
- 使う: 統合候補・分割候補・依存破綻など包括的な再設計判断が必要なとき
- 使わない: workflow が参照する scripts / hooks / validators / CLI の実装整合性まで見たいとき。その場合は `/review-workflow-runtime` を使う
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
ただし、Global を明示指定された場合は `%APPDATA%/Code/User/prompts/` と `~/.copilot/` の両方を対象に含めてよい。
上記のいずれかがあればレビューを続行する。
上記が無ければ、ワークスペースの目的・構造・言語・主要ツールを見て最小限の設計資産を提案または生成してからレビューする。

`AGENTS.md` または `.github/copilot-instructions.md` を対象に含む場合は、両方を常時インストラクションとしてセットで読み、役割差分と重複を確認する。

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
10. Frontmatter: `.instructions.md` / `.prompt.md` / `.agent.md` の `description` / `applyTo` / `name` 等が用途に合うか、`applyTo` が過大でないか、glob クォートが統一されているかを確認する。可能なら file type ごとの必須項目と unsupported property を**機械的にも検査**する。`SKILL.md` は明示指定時のみ `name` / `description` / 自己完結性を確認する
11. Deterministic Offload: extract / count / validate / diff / format / parse / lint など決定論的に書ける処理が LLM / agent ループに紛れ込んでいないか。混じっていれば script / IR / hook へ逃がす（Reference Skill の `references/review-checklist.md` の Deterministic Offload Check を参照）
12. Refactor Order: 新規追加を提案する前に、削除 / 統合 / 分離 / 移動で解けないかを確認する
13. Always-On Boundary: `copilot-instructions.md` と `AGENTS.md` が常時インストラクションとして役割分離され、同じ intake / routing / catalog を二重保持していないかを確認する
14. Elevation Wording: always-loaded entry に強い命令語があり、直下の catalog、reference list、workflow map、rule inventory を昇格させていないか
15. Runtime Boundary: 指摘対象が default conversational behavior に影響する always-loaded entry か、review-only の invoked asset か
16. Casual Input Safety: 挨拶、短い質問、番号だけ返答などの軽い入力で、不必要に task intake へ倒れないか
17. Cross-Scope Entry: 必要な場合、workspace 側だけでなく User Data 側の always-loaded entry も合わせて確認したか
18. Context Compression: 本文が AI 判断に必要な最小情報か。冗長な前置き・人間向け装飾・自明な内容・AI に委ねてよい具体数値が肥大していないか
19. Preservation Guard: ユーザー固有事実 / ID / パス / 参考URL / 設計根拠 / Example 最低1つ / 運用メタコメント（`syncToGlobal` / `author` / `license` 等）を圧縮提案で誤って削らないか

## Review Flow

1. Context Gate を通す
2. Quick Check の全項目を評価する
3. 標準チェックを必ず実施する
4. 標準チェックの結果を踏まえて、各改善案を `削除 / 統合 / 分離 / 移動 / 追加 / 維持` のいずれかに分類する
5. 優先度順に返す
6. 追加提案がある場合は、削除 / 統合 / 移動で解けない理由を短く添える
7. 提案全体に DRY 違反や append-only 傾向がないかを見直す

## 標準チェック（必須）

- Cross-reference: AGENTS と各 agent/instructions の記述整合
- Prompt 重複: `.instructions.md` や always-loaded entry の重複は強く問題視する。一方、明示呼び出し前提の `.prompt.md` は役割近接だけで即統合候補にせず、本文内の自己重複、description 競合、呼び分け不能、更新漏れリスクがある場合を優先して指摘する
- Architecture: `削除 / 統合 / 分離 / 移動 / 追加 / 維持` と、必要に応じたパージ候補の判定
- Efficiency: 同一 prompt 内の不要な重複操作、差分ベースで済むフル実行、1 コマンドに統合可能な連続操作
- Refactor Order: `削除 → 統合 → 分離 → 移動 → 追加` の順で提案が整理されているか
- Bloat Check: 提案後のファイルが append-only 化していないか。圧縮・置換・削除で済む内容を新節として足していないか
- Small File Tolerance: 50 行以下のファイルは原則「変更不要」。レビュー観点に明確な問題があるときだけ提案する
- Generic Rule Placement: repo local の generic design instruction が skill / reference と重複していないか。重複していれば上位 SSOT へ寄せ、local は差分だけにするか削除する
- Always-On Boundary/DRY-SSOT: `.github/copilot-instructions.md` は repo-wide の短い入口、`AGENTS.md` は agent / workflow の索引または薄い共通 guardrail として分離されているか。同じ routing、intake、catalog、詳細手順を二重保持していないか
- Elevation Structure Check: 強い命令語単体ではなく、strong wording と下位の重い構造の近接を確認する
- Catalog Collision Check: entry file に catalog、resource map、workflow list、detailed references が混在していないか
- Runtime Classification: 各指摘が runtime-affected か review-only かを分類する
- Casual Input Probe: 軽い conversational input で forced routing が起きる設計になっていないかを確認する
- Frontmatter Hygiene: `.instructions.md` / `.prompt.md` / `.agent.md` の `description` 欠落、必要な `applyTo` 欠落、過剰スコープ（手動参照用なのに `**`）、クォート不統一、`syncToGlobal` / 著者メタの欠落
- IR File Hygiene: IR は原則 in-memory になっているか。中間 file を導入している場合は、deterministic handoff の理由と cleanup 方針があるか
- Link Integrity: 相対 Markdown link が実在ファイルを指しているかを確認する。可能なら grep や script で**機械的に検査**する
- Agent Placement: `.github/agents/` 直下以外の `.agent.md` は VS Code scan 対象外。テンプレ用途なら `.md` 化または skill/reference へ集約し、参照元を更新する。未参照なら削除候補にする
- Skill Scope: `SKILL.md` は明示指定時のみ、`name` / `description` / `argument-hint` / `user-invocable` と、単体で使える自己完結性を確認する
- Global Prompt DRY/SSOT: Global User Data 側の prompt や Agent は単体利用前提で、ファイル内で自己完結する DRY/SSOT が保てているか

## 優先度

- 🔴P0 Critical: 依存破損、Cross-reference 破綻
- 🟠P1 High: SSOT違反、God Agent、I/O 不明瞭
- 🟡P2 Medium: 冗長・統合余地・回復性不足
- 🟢P3 Low: 文体・軽微な整形

## Completion Criteria

- Context 読み込み完了
- Quick Check 全項目評価完了
- 標準チェック実施完了
- Cross-reference 検証完了
- 各改善案の `削除 / 統合 / 分離 / 移動 / 追加 / 維持` 分類完了
- 新規追加案について、削除 / 統合 / 移動で解けない理由の確認完了
- 提案後の肥大化チェック完了
- `copilot-instructions.md` / `AGENTS.md` の常時インストラクション境界と DRY/SSOT の確認完了
- runtime-affected と review-only の分類完了
- casual input に対する forced routing リスクの確認完了
- frontmatter と相対 link の検査完了（対象に含まれる場合）
- 本文圧縮余地と誤削除ガード（運用メタコメント等）の確認完了
- 出力フォーマット準拠

## Output Format

### ✅ Good Points
- {良い点}

### ⚠️ Improvements Needed
- {優先度} [{削除|統合|分離|移動|追加|維持}] {カテゴリ}: {file}:{line} → {解決策}（Global/User Data 対象は `%APPDATA%/Code/User/prompts/<file>`、`~/.copilot/<path>` 形式も可）
- 例: High [分離] Always-On Boundary: .github/copilot-instructions.md:12 → catalog を entry file から docs へ移動し、入口には会話境界だけを残す | Impact=runtime-affected | Trigger=wording + catalog

### Runtime Impact
- runtime-affected: always-loaded entry の既定会話挙動に影響する指摘
- review-only: review asset や invoked asset の改善指摘であり、それ自体では既定会話挙動を変えない

### Trigger Shape
- wording-only
- wording + catalog
- duplicated entry routing
- always-loaded boundary violation

### Recommendation
- {総合評価と次アクション}
