---
name: "retro-private-skills"
description: "private skill repo の .github/skills に SKILL 知見や修正を反映し、ローカル commit まで行う。Use when: private skill retro, skill repo authoring, private skill fix, retro private skills. workspace の .github/skills は更新しない。private repo path は明示指定でもよい"
argument-hint: "会話要約、エラー、diff、対象 skill、private repo path（任意）、mode（safe-auto / review-only）"
agent: "agent"
tools: ["agent", "edit/editFiles", "execute/runInTerminal"]
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# retro private skills

セッションやインシデントから再利用可能な知見を抽出し、private skill repo の `.github/skills/<skill>/` へ統合する。authoring とローカル commit までを担当し、remote push や public 同期はしない。

## When to Use

- 使う: private repo の既存 SKILL に残すべき手順、判断基準、失敗回避策を見つけたとき
- 使う: private repo の `SKILL.md` や `references/*` を小さく直して確定したいとき
- 使わない: workspace の `.github/skills/**` 直編集
- 使わない: public repo への push や公開同期。`sync-public-skills` に handoff
- 使わない: User Data の修正は `retro-user` に handoff。`~/.copilot/skills` の修正はこの prompt の対象外として停止する
- 使わない: SKILL 以外の `.github/**` や `AGENTS.md`。`retro-workspace` に handoff

## 入力

エラーログ / Git diff / 会話履歴 / ターミナル履歴 / 対象 skill 名 / private repo path（任意）のいずれか 1 つ以上。なければ追加要求して停止。

## Execution Mode

- 既定は `safe-auto`。`review-only` / `dry-run` / `プレビュー` が明示された場合だけ、変更案を提示して停止する
- private skill scope が明確で、Safety Gate を通過し、既存 skill への小〜中規模な統合・更新で済む場合は、確認なしで反映まで実行してよい
- 次の場合だけユーザー確認で停止する: scope 判断が曖昧、大規模削除、既存 skill の意味を大きく変える変更、public/private の同期範囲に関わる変更、secret / 個人情報 / 環境固有値の扱いに迷う場合
- typo・小さな手順補正・既存ルールの抜け補完・確認フローの簡素化は、safe-auto でそのまま反映する

## Safety Gate

- 反映禁止: secret / 認証情報 / 個人情報 / 顧客情報 / ローカル絶対パス / 端末固有値
- memory 系スコープ（`/memories/**` 等）は反映先にしない
- workspace / repository の `.github/**` や `AGENTS.md`、User Data、`~/.copilot/skills` に置くべき内容はこの prompt では扱わず、scope 不一致として停止する
- Gate 失敗時は理由と安全な代替案を出して停止する

## 反映先

- source of truth は次の順で解決する
- 1. 入力で明示された `private repo path`
- 2. `SYNC_PUBLIC_SKILLS_PRIVATE_REPO` の Process scope
- 3. `SYNC_PUBLIC_SKILLS_PRIVATE_REPO` の User scope
- 4. `SYNC_PUBLIC_SKILLS_SCRIPT` が解決できる場合は、その script path から repo root を逆算した private repo
- 5. current workspace が private skill repo の構造（`.github/skills/` と sync script 相当）を持つ場合は、その workspace root
- 上記のいずれでも private repo root を確定できない場合だけ `private repo 未解決` で停止する
- workspace の `.github/skills/**` は更新しない
- `SKILL.md` が太る場合は `references/*` に分離する
- local-only な知見は、公開可能な一般ルールへ抽象化できる場合だけ反映する
- `memory`、一時ログ、単発メモは反映しない

## Refactor Rules

- SSOT を守る。重複定義は統合する
- 新規ファイルより既存 skill への統合を優先する
- 冗長説明は圧縮するが、非自明な判断基準や手順は消さない
- append-only に節を足し続けるのを通常運用とみなさない
- 変更前に `削除 -> 統合 -> 分離 -> 追加` の順で検討する
- 同じ Learning / Evidence / Impact を言い換えて繰り返さない。1 論点 1 塊でまとめる

## 実行手順

### 1. 知見抽出

- private repo root を解決し、`.github/skills/` の存在を確認する
- `Learning / Evidence / Impact` を作り、最も specific な既存 skill に routing する
- actionable な知見がなければ停止

### 2. 変更案作成

- 優先度: Impact x Recurrence（P1/P2/P3）
- 対象 skill が明示されている場合は、その skill を先に読み、広い探索を後回しにする
- まず既存 skill へ統合できないかを見る
- 適切な既存 skill が無い場合は、新規 skill 候補、狙い、既存 skill に収まらない理由を `New Skill Proposal` として提示して停止する。明示承認なしに scaffold しない
- 既存 skill が長くなりすぎていないか、同じ概念を複数 skill に重複定義していないかを確認する
- `SKILL.md` が太る場合は、既存文の置換や圧縮で済むかを先に確認し、それでも重い場合だけ `references/*` への分離を検討する
- 最小差分で反映する
- safe-auto ではファイル編集まで実行する。review-only 指定時と Gate 停止時だけ提案に留める

### Context Refactor Gate

- 対象が `SKILL.md` のときは、追加より先に既存節の圧縮や `references/*` への分離を検討する
- `行数が増える = 改善` とみなさない
- private skill repo では、同じ学びを複数 skill に重複定義するより、最も specific な 1 skill へ寄せる方向を優先する

### 3. 反映 + 必要時承認

- safe-auto で対象ファイルを作成・編集する
- 確認が必要な条件に該当する場合だけ、対象・理由・影響を示してユーザー承認後に反映する
- Gate: private skill scope 確認済み / 重複なし / 既存 skill 設計と矛盾なし / Safety Gate 通過済み

### 3.5. 肥大化チェック（反映後）

- 反映後、編集したファイルに DRY 違反・冗長表現・重複定義がないかを確認する
- あれば圧縮・削除・分離を実施し、報告に `肥大化チェック` を含める

### 4. 報告

```markdown
# Retro: [Title]

## Learnings
1. **Learning**: ...
	- Evidence: ...
	- Impact: ...

## Changes
- ...

## Target Rationale
- ...

## New Skill Proposal
- なし / または新規 skill 候補と理由

## Review Checkpoint
- [ ] safe-auto executed or user approval obtained when gated
- [ ] Private skill scope confirmed
- [ ] No duplicate rules across skills
- [ ] Safety Gate passed
```

Stop: 入力不足 / actionable な知見なし / explicit path・env・script 逆算・workspace fallback の全失敗による private repo 未解決 / scope 不一致 / Safety Gate 失敗 / 新規 skill 候補 / review-only
