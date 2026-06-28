---
name: "retro-private-skills"
description: "VS Code workspace `.github/skills` から private skill repo へ intake・育成する prompt 版。CLI / Scout の `~/.copilot/skills|m-skills` intake は SKILL 版を使う。Use when: private skill retro, skill repo authoring, private skill fix, workspace skill intake, retro private skills。User Data は retro-user、通常の workspace 資産は retro-workspace を使う"
argument-hint: "会話要約、エラー、diff、対象 skill、workspace skill path、private repo path（任意）、mode（safe-auto / review-only）"
agent: "agent"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# retro private skills

セッションやインシデント、または VS Code workspace の skill から再利用可能な知見を抽出し、private skill repo の既存 skill へ最小差分で統合する。safe-auto では authoring 後に local commit まで行う。private repo が origin より 3 commits 以上 ahead なら、明示指示がなくても push まで行う。public sync は行わない。

これは VS Code workspace 用の prompt 版。intake source は **VS Code workspace の `.github/skills/**`**（例: `<workspace>/.github/skills/c360-operations`）。`~/.copilot/skills|m-skills` の intake は CLI / Scout 用の `retro-private-skills` SKILL が担当する。育成先（write target）はどちらも private repo の `.github/skills/<skill>/`。

## When to Use

- 使う: VS Code workspace の `.github/skills/<skill>` を private repo へ取り込み・育成したいとき
- 使う: private repo の既存 skill に残すべき手順、判断基準、失敗回避策を見つけたとき
- 使う: private repo の `SKILL.md` / `references/*` を小さく直して確定したいとき
- 使わない: `~/.copilot/skills|m-skills` の取り込み（CLI / Scout 用 `retro-private-skills` SKILL の担当）、public repo への同期、User Data、SKILL 以外の `.github/**` や `AGENTS.md`

## 入力

エラーログ / Git diff / 会話履歴 / ターミナル履歴 / 対象 skill 名 / private repo path（任意）のいずれか 1 つ以上。なければ追加要求して停止。

## Mode

- 既定は `safe-auto`。`review-only` / `dry-run` / `プレビュー` が明示された場合だけ、変更案を提示して停止する
- scope 明確 + Safety Gate 通過 + 既存 skill への小〜中規模更新なら、確認なしで反映してよい
- safe-auto で private repo に変更を入れた場合は、検証後に skill 単位の local commit を作成し、working tree を clean にして完了する
- local commit 後に private repo が origin より 3 commits 以上 ahead なら、明示指示がなくても `git push` まで行う。push 前に remote が private repo であること、working tree が clean であること、push 対象が今回までの local commits だけであることを確認する
- ahead が 1〜2 commits の場合は push しない。public sync、release、tag、force push は明示指示があるときだけ行う
- dirty primary skill changes は authoring / intake material として扱う。safe-auto では対象 skill の変更だけを stage / commit し、無関係 dirty は触らない
- public / internal / EMU sync は行わない。反映先へ配る必要がある場合は、`Next Step / Handoff` に従う
- scope 曖昧、大規模削除、意味変更、public/private 境界の変更、secret / 個人情報 / 環境固有値の扱いに迷う場合だけ確認で停止する

## Next Step / Handoff

public / EMU / GIM へ反映する必要がある場合は、育成と local commit 完了後に `/sync-public-skills <skill-name>` へ hand off する。retro 中に public sync は実行しない。

## Scope Gate

- intake source は VS Code workspace の `.github/skills/<skill>`、または private repo 内の既存 skill。`~/.copilot/skills|m-skills` を source にしたいときは CLI / Scout 用 SKILL 版へ回す
- 反映先（write target）は private repo の `.github/skills/<skill>/` に限定する。workspace の `.github/skills/**` は読み取り専用 source として扱い、書き込みは private repo 側だけに行う
- secret / 認証情報 / 個人情報 / 顧客情報 / ローカル絶対パス / 端末固有値 / `/memories/**` は反映しない
- workspace / repository の SKILL 以外の `.github/**`、`AGENTS.md`、User Data に置くべき内容は scope 不一致として停止する
- Skill に戻す内容は、その skill の目的に直接効く汎用 workflow / Gotchas / 検証観点に限定し、コピー先でも壊れない自己完結な知識として残す。workspace 固有の顧客名、案件名、ファイル構造、運用ルールは抽象化できる場合だけ残し、抽象化できなければ scope 不一致として停止し、workspace スコープの記録や workflow への切り出しを提案する
- actionable な知見なし、private repo 未解決、または gate 失敗時は理由と代替案を示して停止する

## Intake 前段（任意）

prompt 版の intake は VS Code workspace の `.github/skills/<skill>` を private repo の `.github/skills/<skill>/` へ取り込む前段。`~/.copilot/skills|m-skills` のミラー（`scripts/Sync-CopilotSkillsToPrivateRepo.ps1` 経由）は CLI / Scout 用 SKILL 版の担当で、ここでは扱わない。

intake は retro 育成本体とは別操作で、ユーザーが明示的に「取り込む / intake / 最新化」を求めたときだけ走る。retro 単発の既定は育成のみ（未育成の生コピー混入を防ぐ）。

- intake あり育成あり: 「この workspace skill を取り込んで育てて」→ workspace から copy → 通常の retro 育成
- intake のみ: 「取り込むだけ」→ copy のみで育成スキップ
- 既定（retro 単発）: intake skip、既存 private skill の育成のみ

workspace skill を取り込むときは、source の `.github/skills/<skill>` を読み取り、顧客名 / 案件名 / ファイル構造 / 運用ルールなど workspace 固有値を抽象化したうえで `<private-repo>/.github/skills/<skill>/` に書き込む。抽象化できない固有値はそのまま残さず、生コピーを private repo に置かない。

## Edit Rules

- private repo root は `private repo path` → `SYNC_PUBLIC_SKILLS_PRIVATE_REPO` の Process/User → `SYNC_PUBLIC_SKILLS_SCRIPT` からの逆算 → current workspace の順で解決する
- 新規ファイルより既存 skill への統合を優先し、`削除 -> 統合 / 圧縮 -> 分離 -> 追加` の順で検討する
- 圧縮は AI が判断できる最小情報を主目的にし、人間向け可読性は二次とする
- 冗長説明は圧縮するが、非自明な判断基準や手順は消さない
- `SKILL.md` が太る場合も、まず既存文の置換や圧縮を優先し、それでも重い場合だけ `references/*` を使う
- `SKILL.md` は一般論の手順書ではなく入口として扱う。追加するなら、モデルが既に知っている自明な手順より、実作業で踏んだ Gotchas、完了判定、参照すべき scripts / references の所在を優先する
- 同じ Learning / Evidence / Impact を言い換えて繰り返さず、1 論点 1 塊でまとめる
- `git add` / `git commit` / `git push` の直前に、`Set-Location <private-repo>` または `git -C <private-repo>` で working directory を private repo root に固定する。前の tool call から引き継いだ cwd を信用しない。commit / push 後に `git status --short --branch` を再確認して cwd 違いの commit を早期検知する

## 実行手順

### 1. 知見抽出

- private repo root を解決し、`.github/skills/` の存在と対象 skill を確認する
- `git status --short --branch` と ahead/behind を確認し、dirty path を skill 単位に分類する。対象 skill 以外の dirty は stage しない
- intake する場合は source の workspace `.github/skills/<skill>` を読み取り、private repo 側の同名 skill の有無を確認する
- `Learning / Evidence / Impact` を作り、最も specific な既存 skill に routing する

### 2. 変更案作成

- 優先度: Impact x Recurrence（P1/P2/P3）
- 対象 skill が明示されている場合は、その skill を先に読む
- まず既存 skill へ統合できるかを確認し、収まらない場合だけ `New Skill Proposal` を出して停止する
- 対象が `SKILL.md` のときは、追加より先に既存節の圧縮や置換を検討する
- 複数 skill が独立して owning すべき cross-cutting 原則（例: tool-platform 制約、Self-Contained ノート、commit/push 論理）は、該当する全 skill に 1 行だけ追加する複数反映を許可する。portability を守るための独立 SSOT コピーで、hard reference に依存しない形を取る
- safe-auto では最小差分で反映し、review-only と Gate 停止時だけ提案に留める

### 3. 反映 + 必要時承認

- safe-auto で編集し、検証後に skill 単位で local commit する。commit message は Conventional Commits にする
- 確認が必要な条件に該当する場合だけ、対象・理由・影響を示して承認後に反映する

### 3.5. 肥大化チェック（反映後）

- 反映後、DRY 違反・冗長表現・重複定義があれば圧縮・削除・分離する

### 4. 検証

- 変更先が private repo の `.github/skills/<skill>/` 配下だけであることを確認する
- 新規または大きく変更した `SKILL.md` は、folder 名と `name` の一致、trigger を含む `description`、必要な `argument-hint` / `user-invocable` / `license` / `metadata.author` を確認する
- 追加内容が secret、顧客情報、tenant ID、ローカル絶対パス、外部 workspace 依存を含まないことを確認する
- safe-auto で変更した場合は、local commit 作成後に private repo の working tree が clean であることを確認する。origin より 3 commits 以上 ahead なら、private remote と clean 状態を再確認して push し、push 後に ahead が解消したことを確認する

## Example Report

```markdown
# Retro: [Title]
- Learnings: ...
- Changes: ...
- Target: ...
- Commit: <hash or none>
- Gate: pass / stop reason
```

Stop: 入力不足 / private repo 未解決 / scope 不一致 / Safety Gate 失敗 / actionable な知見なし / 新規 skill 候補 / review-only