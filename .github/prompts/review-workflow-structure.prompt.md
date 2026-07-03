---
name: "review-workflow-structure"
description: "ワークフロー設計資産としての agent / instruction / prompt / AGENTS を横断レビューし、SSOT・整合性・構造の問題を検出する"
argument-hint: "対象パス、review 観点、all / 徹底的 などの範囲指定"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# review workflow structure

エージェント定義（`.agent.md`）と customization 指示（`.instructions.md` / `.prompt.md` / entry files）を、構造・SSOT・配置の観点で横断レビューする入口 prompt。実装 runtime の挙動確認は `/review-workflow-runtime` を使う。

## Use / Do Not Use

- 使う: agent / instruction / prompt / entry file を横断して、SSOT、配置、発火条件、肥大化、依存破綻を確認したいとき。
- 使う: `fix` / `ALLFIX` 指定があり、低リスクな customization 変更まで自律実行したいとき。
- 使わない: scripts / hooks / validators / CLI の実装整合性が主題のとき。その場合は `/review-workflow-runtime` を使う。
- 使わない: 単一ファイルの文章圧縮だけが目的のとき。対象ファイルを直接編集する。

## Scope Gate

- 既定: workspace の `AGENTS.md`、`.github/copilot-instructions.md`、`.github/agents/*.agent.md`、`.github/instructions/**/*.instructions.md` を対象にする。
- `all` / `徹底的`: 上記に `.github/prompts/*.prompt.md` と、現在セッションで自動ロードまたは明示参照された workspace 側 instruction injection files を加える。
- Global/User Data: 引数に `global`、`User Data`、`%APPDATA%`、`~/.copilot` がある、または対象ファイルが明示添付された場合だけ含める。
- Skills: `skill` / `SKILL.md` / skill folder が明示された場合だけ `SKILL.md` の frontmatter と自己完結性を対象にする。`agentic-workflow-guide` は、存在する場合のみ rubric の SSOT として読む。
- `AGENTS.md` または `.github/copilot-instructions.md` を含む場合は、必ず両方を読み、常時入口の役割差分と DRY/SSOT を確認する。

対象が存在しない場合は、ワークスペースの目的・構造・主要ツールから最小限の設計資産を提案する。生成はユーザーが `fix` / `create` を指定した場合だけ行う。

## Rubric SSOT

ワークスペースに `.github/skills/agentic-workflow-guide/` がある場合は、判定基準を次に委譲する。

- `.github/skills/agentic-workflow-guide/SKILL.md`
- `.github/skills/agentic-workflow-guide/references/review-checklist.md`
- `.github/skills/agentic-workflow-guide/references/design-principles.md`

この prompt は入口・スコープ・出力契約だけを持つ。checklist を再掲しない。

## Required Review Dimensions

rubric SSOT が無い場合、または最終 sanity check では、次だけを確認する。

- Placement / SSOT: always-loaded、path-scoped、task prompt、skill、agent、docs の置き場が正しいか。
- Always-On Boundary: `copilot-instructions.md` と `AGENTS.md` が短い入口に留まり、catalog / workflow map / reference list を昇格させていないか。
- Primitive / SRP: prompt / instruction / skill / agent / hook の選択が最小で、1 agent が 1 責務か。
- Frontmatter / Placement: `.prompt.md` / `.instructions.md` / `.agent.md` の supported fields、`applyTo` 過大、`.github/agents/` 直下配置を確認する。
- Deterministic Offload: extract / count / validate / diff / format / parse / lint が LLM loop に混ざっていないか。
- Link Integrity: 相対 Markdown link が実在するか。機械検査では code span / fenced code 内の記法例、`URL` / `url` / `image-url` などの placeholder target を除外する。
- Context Compression / Preservation: 冗長な再掲を削りつつ、ユーザー固有事実、運用メタコメント、根拠、必要な Example を誤削除しないか。
- Runtime Classification: 各 finding を `runtime-affected` / `review-only` に分け、casual input forced routing の有無を確認する。

## Fix Policy

`fix` / `ALLFIX` / `自動修正` 指定がある場合は、次の順で低リスク修正を実行する。

1. 削除: 古い節、孤立した重複、入口に不要な catalog 誘導を削る。
2. 統合: 同じ概念の再掲を 1 つにまとめ、SSOT 参照へ置き換える。
3. 分離 / 移動: always-loaded にある詳細を scoped instruction、prompt、skill、docs へ移す。
4. 追加: 削除 / 統合 / 移動で解けない場合だけ追加する。

自動修正してよいもの: 明示対象の prompt 圧縮、リンク切れ修正、supported frontmatter への小修正、未参照であることを確認した孤立コメントの削除。

自動修正しないもの: `AGENTS.md` / `copilot-instructions.md` へ metadata 目的だけで YAML frontmatter を追加する変更、generated marker の削除判断が未検証の変更、Global prompt を workspace prompt へ複製する変更、大規模 agent rewrite、公開同期、履歴改変。

## Review Flow

1. Scope Gate を通す。
2. 必要な rubric / entry / target files だけ読む。
3. frontmatter、agent placement、relative links を可能な範囲で機械検査する。relative link 検査は code span / fenced code と placeholder target を false positive として除外する。
4. finding を優先度順に出し、`削除 / 統合 / 分離 / 移動 / 追加 / 維持` に分類する。
5. `fix` 指定時は低リスク修正を適用し、同じ観点で再レビューする。最大 3 回で止め、残件があれば理由を報告する。
6. 追加提案には、削除 / 統合 / 移動で解けない理由を添える。

## Output Format

### ✅ Good Points
- {良い点}

### ⚠️ Improvements Needed
- {Priority} [{削除|統合|分離|移動|追加|維持}] {Category}: {file}:{line} → {fix} | Impact={runtime-affected|review-only} | Trigger={wording-only|wording + catalog|duplicated entry routing|always-loaded boundary violation|other}

### Runtime Impact
- runtime-affected: {既定会話挙動や always-loaded entry に影響する残件}
- review-only: {invoked asset / review asset のみの残件}

### Verification
- {実施した read / grep / link / frontmatter / subagent review / 再レビュー}

### Recommendation
- {総合評価、修正済みファイル、残リスク、次アクション}
