---
name: "retro-private-skills"
description: "private skill repo の既存 SKILL / references に知見や修正を反映し、必要ならローカル commit まで行う。Use when: private skill retro, skill repo authoring, private skill fix, retro private skills"
argument-hint: "会話要約、エラー、diff、対象 skill、private repo path（任意）、mode（safe-auto / review-only）"
agent: "agent"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# retro private skills

セッションやインシデントから再利用可能な知見を抽出し、private skill repo の既存 skill へ最小差分で統合する。authoring と必要時の local commit までは扱うが、remote push や public sync は行わない。

## When to Use

- 使う: private repo の既存 skill に残すべき手順、判断基準、失敗回避策を見つけたとき
- 使う: private repo の `SKILL.md` / `references/*` を小さく直して確定したいとき
- 使う: private の `copilot-skills/` にミラーされた `.copilot` 由来 skill への学び統合（編集先は元の `~/.copilot/skills|m-skills/<name>/`）
- 使わない: workspace の `.github/skills/**`、public repo への同期、User Data、SKILL 以外の `.github/**` や `AGENTS.md`

## 入力

エラーログ / Git diff / 会話履歴 / ターミナル履歴 / 対象 skill 名 / private repo path（任意）のいずれか 1 つ以上。なければ追加要求して停止。

## Mode

- 既定は `safe-auto`。`review-only` / `dry-run` / `プレビュー` が明示された場合だけ、変更案を提示して停止する
- scope 明確 + Safety Gate 通過 + 既存 skill への小〜中規模更新なら、確認なしで反映してよい
- scope 曖昧、大規模削除、意味変更、public/private 境界の変更、secret / 個人情報 / 環境固有値の扱いに迷う場合だけ確認で停止する

## Scope Gate

- 反映先は private repo の `.github/skills/<skill>/`、または `.copilot` 由来 skill の元 `~/.copilot/skills|m-skills/<skill>/` に限定する
- secret / 認証情報 / 個人情報 / 顧客情報 / ローカル絶対パス / 端末固有値 / `/memories/**` は反映しない
- workspace / repository の `.github/**`、`AGENTS.md`、User Data に置くべき内容は scope 不一致として停止する
- `.copilot` 由来 skill への学びは、private の `copilot-skills/` コピーではなく元の `~/.copilot/skills|m-skills/<name>/` を編集する。`copilot-skills/` 直下は同期で上書きされるため直接編集しない
- Skill に戻す内容は、その skill の目的に直接効く汎用 workflow / Gotchas / 検証観点に限定する。workspace 固有の顧客名、案件名、ファイル構造、運用ルールは抽象化できる場合だけ残し、抽象化できなければ `retro-workspace` へ handoff する
- actionable な知見なし、private repo 未解決、または gate 失敗時は理由と代替案を示して停止する

## Intake 前段（任意）

intake は `~/.copilot/skills` と `~/.copilot/m-skills` を private repo の `copilot-skills/{skills,m-skills}/` へ機械的にミラーする前段。retro 育成本体とは別操作で、ユーザーが明示的に「取り込む / intake / 最新化」を求めたときだけ走る。retro 単発の既定は育成のみで、intake は実行しない（未育成の生コピー混入を防ぐ）。

- intake あり育成あり: 「`.copilot` から取り込んで育てて」→ intake → 通常の retro 育成
- intake のみ: 「取り込むだけ」→ intake を実行し育成はスキップ
- 既定（retro 単発）: intake skip、育成のみ

実行は private repo の `scripts/Sync-CopilotSkillsToPrivateRepo.ps1`（旧 `sync-copilot-skills` skill から移設）。出自別に `copilot-skills/skills/` と `copilot-skills/m-skills/` へ分離コピーし README を自動生成する。この機械的ミラーだけは `copilot-skills/` へ書き込むが、学びの統合（authoring）は引き続き元の `~/.copilot/skills|m-skills/<name>/` を編集し、`copilot-skills/` 直下は直接編集しない。

## Edit Rules

- private repo root は `private repo path` → `SYNC_PUBLIC_SKILLS_PRIVATE_REPO` の Process/User → `SYNC_PUBLIC_SKILLS_SCRIPT` からの逆算 → current workspace の順で解決する
- 新規ファイルより既存 skill への統合を優先し、`削除 -> 統合 / 圧縮 -> 分離 -> 追加` の順で検討する
- 圧縮は AI が判断できる最小情報を主目的にし、人間向け可読性は二次とする
- 冗長説明は圧縮するが、非自明な判断基準や手順は消さない
- `SKILL.md` が太る場合も、まず既存文の置換や圧縮を優先し、それでも重い場合だけ `references/*` を使う
- `SKILL.md` は一般論の手順書ではなく入口として扱う。追加するなら、モデルが既に知っている自明な手順より、実作業で踏んだ Gotchas、完了判定、参照すべき scripts / references の所在を優先する
- 同じ Learning / Evidence / Impact を言い換えて繰り返さず、1 論点 1 塊でまとめる

## 実行手順

### 1. 知見抽出

- private repo root を解決し、`.github/skills/` の存在と対象 skill を確認する
- `Learning / Evidence / Impact` を作り、最も specific な既存 skill に routing する

### 2. 変更案作成

- 優先度: Impact x Recurrence（P1/P2/P3）
- 対象 skill が明示されている場合は、その skill を先に読む
- まず既存 skill へ統合できるかを確認し、収まらない場合だけ `New Skill Proposal` を出して停止する
- 対象が `SKILL.md` のときは、追加より先に既存節の圧縮や置換を検討する
- safe-auto では最小差分で反映し、review-only と Gate 停止時だけ提案に留める

### 3. 反映 + 必要時承認

- safe-auto で編集し、必要なら local commit まで行う
- 確認が必要な条件に該当する場合だけ、対象・理由・影響を示して承認後に反映する

### 3.5. 肥大化チェック（反映後）

- 反映後、DRY 違反・冗長表現・重複定義があれば圧縮・削除・分離する

## Example Report

```markdown
# Retro: [Title]
- Learnings: ...
- Changes: ...
- Target: ...
- Gate: pass / stop reason
```

Stop: 入力不足 / private repo 未解決 / scope 不一致 / Safety Gate 失敗 / actionable な知見なし / 新規 skill 候補 / review-only