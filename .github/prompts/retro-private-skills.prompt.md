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

セッションやインシデント、または VS Code workspace の skill から再利用可能な知見を抽出し、private skill repo の既存 skill へ最小差分で統合する。safe-auto では authoring 後に local commit と push まで行う。複数 PC / 複数セッションから同じ private repo を触る前提で、編集前に必ず同期し、commit を滞留させない。public sync は行わない。

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
- 複数 PC / 複数セッションから同じ private repo を触るため、**local commit を滞留させない**。skill 単位 commit を作ったら、明示指示がなくてもそのまま `git push` する（ahead 件数の閾値は設けない）。この prompt の実行自体を push 承認として扱い、global の「明示指示なし push 禁止」をここだけ override する
- push 前に `git fetch origin` してから ahead/behind を再計算し、remote URL が期待する private skill repo（owner/repo）と一致すること、working tree が clean であること、push 対象が「今回の run で作った commit」または「preflight で `origin/<branch>..HEAD` を確認し対象 skill だけと判定した既存 ahead commit」に限られることを確認する
- push が reject されたら（別 PC が先に push 済み）`git pull --rebase` で取り込んでから再 push する。force push、public sync、release、tag は明示指示があるときだけ行う
- push したくない draft を手元に残したい場合は safe-auto を使わず、`review-only` / `dry-run` / `プレビュー` を指定する
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
- **編集前の git preflight は `fetch -> 分類 -> dirty 処理 -> ahead 処理 -> pull --rebase` の順で行う**。順序を崩すと、無関係 dirty が残ったまま rebase を試して refuse されるし、clean を要求する push gate も通らない
  1. `git -C <private-repo> fetch origin` を実行する。fetch なしの ahead/behind は stale な remote-tracking ref の値。upstream 未設定なら `@{upstream}` の確認自体が失敗するので、`origin/<branch>` を明示解決するか upstream を設定してから続行する
  2. `git status --short --branch` で ahead / behind / dirty を確認し、dirty path を skill 単位に分類する
  3. dirty を先に消す。対象 skill の dirty は commit する。**無関係 dirty を残したまま `pull --rebase` してはいけない**（unstaged changes があると rebase は refuse する）し、`--autostash` で隠すのも禁止。無関係 dirty が残るなら safe-auto では停止して扱いを確認するか、clean な worktree / 一時 clone を作ってそこで対象 skill だけを処理して push する
  4. working tree が clean になったら ahead を再評価する。ahead が 0 でなければ、push は `origin/<branch>..HEAD` 全体を送るため滞留 commit が今回の push 承認に巻き込まれる。`git log --oneline --stat origin/<branch>..HEAD` で commit と touched paths を列挙し、対象 skill だけなら Mode の push gate を通して先に push し ahead 0 にする。対象外の commit が混ざる場合は safe-auto では停止し、扱いを確認する
  5. behind があれば `git pull --rebase` する。別 PC の更新を取り込まずに編集すると、同じ skill を古い版ベースで書き換えて conflict になる
  6. rebase が conflict したら、both-kept（両方残し）は**一時保存の方針**として使ってよいが最終形にはしない。push 前に、同一論点の重複統合、MUST / 禁止 / 既定 mode の矛盾解消、`SKILL.md` frontmatter の一意性を確認する。解消できない矛盾が残る場合は push せず停止する
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
- safe-auto で変更した場合は、local commit 作成後に working tree が clean であることを確認し、`git fetch origin` で ahead/behind を再計算してから push する。**完了条件は working tree clean かつ ahead 0**。push せずに終わると次に使う PC が古い状態から始まる

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