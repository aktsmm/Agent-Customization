---
name: "retro-workspace-skill"
description: "workspace の .github/skills に SKILL 知見やローカル修正を反映する。Use when: workspace skill, local skill fix, skill retro, SKILL 知見反映。private mirror は行わない"
argument-hint: "会話要約、エラー、diff、対象 skill、mode（safe-auto / review-only）"
agent: "agent"
tools: ["agent", "edit/editFiles", "execute/runInTerminal"]
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# retro workspace skill

セッションやインシデントから再利用可能な知見を抽出し、現在の workspace の `.github/skills/<skill>/` へ統合する。private repo への mirror、公開同期、commit、push はしない。

## When to Use

- 使う: workspace の既存 SKILL に残すべき手順、判断基準、失敗回避策を見つけたとき
- 使う: `.github/skills/<skill>/SKILL.md` や `references/*` を小さく直してすぐ試したいとき
- 使わない: private / public repo への同期。`sync-public-skills` に handoff
- 使わない: User Data や `~/.copilot/skills` の修正。`retro-user` / `retro-copilot` に handoff
- 使わない: SKILL 以外の `.github/**` や `AGENTS.md`。`retro-workspace` に handoff

## Mode

- 既定は `safe-auto`。`review-only` / `dry-run` / `プレビュー` が明示された場合だけ、変更案を提示して停止する

## Scope / Safety

- 反映先は workspace の `.github/skills/<skill>/` のみ
- `SKILL.md` が太る場合は `references/*` に分離する
- 反映禁止: secret、認証情報、顧客情報、社内情報、個人情報、ローカル絶対パス、端末固有値
- local-only な知見は、公開可能な一般ルールへ抽象化できる場合だけ反映する
- `memory`、一時ログ、単発メモは反映しない

## Fast Path

- 対象 skill が明示されている場合は、その skill を先に読み、広い探索を後回しにする
- 追記より `削除 -> 統合/圧縮 -> 分離 -> 追加` を優先する
- 新規 skill は既存 skill に収まらないときだけ候補提示し、明示承認なしに scaffold しない

## Workflow

1. workspace root と `.github/skills/` の存在を確認する
2. `Learning / Evidence / Impact` を作り、最も specific な既存 skill に routing する
3. `safe-auto` では `SKILL.md`、`references/*`、必要最小の `scripts/*` / `assets/*` だけを更新し、更新後に frontmatter、敏感情報、不要な肥大化を確認する

## Report

- Learnings
- Changes
- Target Rationale
- New Skill Proposal（なければ `なし`）
- Safety / Scope Check
- Next

Stop: 入力不足 / actionable な知見なし / scope 不一致 / Safety Gate 失敗 / 新規 skill 候補 / review-only
