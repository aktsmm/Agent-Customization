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

- 使う: workspace の SKILL に残すべき繰り返し可能な手順、判断基準、失敗回避策を見つけたとき
- 使う: 現在の workspace で既存 SKILL の `SKILL.md` / `references/*` / `scripts/*` を小さく更新し、すぐ試したいとき
- 使う: ローカル workspace で作った、または修正した skill をまず workspace 内で整えたいとき
- 使わない: workspace 変更を private skill repo に反映したいとき。代わりに `mirror-workspace-skill-to-private` を使う
- 使わない: public repo へ同期・push したいとき。代わりに `sync-public-skills` を使う
- 使わない: `~/.copilot/skills` の個人 runtime SKILL を直接直すとき。代わりに `retro-copilot` を使う
- 使わない: VS Code User Data prompt / instruction / agent へ反映する知見。代わりに `retro-user` を使う
- 使わない: workspace の SKILL 以外の `.github/**` / `AGENTS.md` へ反映する知見。代わりに `retro-workspace` を使う

## Inputs / Modes

- Input: 会話要約、エラーログ、diff、ターミナル履歴、既存 SKILL、対象 skill 名のいずれか 1 つ以上
- Mode: `safe-auto` / `review-only` / `dry-run` / `プレビュー`。空欄は `safe-auto`

`review-only` / `dry-run` / `プレビュー` が明示された場合は、変更案だけ提示して停止する。

## Scope

| 対象 | 扱い |
| --- | --- |
| workspace `.github/skills/<skill>/` | 既定の反映先 |
| private skill repo `.github/skills/<skill>/` | 対象外。`mirror-workspace-skill-to-private` に handoff |
| `~/.copilot/skills/<skill>/` | 既定では対象外。`retro-copilot` に handoff |
| public skill repo | 対象外。`sync-public-skills` に handoff |
| User Data prompt / instruction / agent | 対象外。`retro-user` に handoff |
| workspace の SKILL 以外の `.github/**` / `AGENTS.md` | 対象外。`retro-workspace` に handoff |

## Safety Gate

- 反映禁止: secret、認証情報、API key、接続文字列、顧客情報、社内情報、個人情報
- 反映禁止: ローカル絶対パス、端末固有値、個人アカウント、公開できないイベント名
- ライセンス不明、公開可否不明、scope 不一致、大きな意味変更は確認で停止する
- local-only な知見は、公開可能な一般ルールへ抽象化できる場合だけ反映する
- `memory`、一時ログ、単発メモは反映先にしない

Gate 失敗時は、理由と安全な handoff 先を示して停止する。

## Refactor Rules

- 追記より更新・統合・置換を優先する
- 新規 skill より既存 skill への統合を優先する
- `SKILL.md` が太る場合は `references/*` へ分離する
- 変更前に `削除 -> 統合/圧縮 -> 分離 -> 追加` の順で検討する
- `name` / `description` / trigger keywords は discovery surface として扱い、必要な場合だけ短く補正する
- 既存ルールの言い換えだけ、単発メモ、同じ失敗の重複記録は反映しない

## Workflow

### 1. Resolve Workspace Skills

1. 現在の workspace root を確認する
2. `.github/skills/` の存在を確認する
3. 無い場合は、作成候補を提示して停止する。ユーザーが明示した場合だけ scaffold に進む

### 2. Extract Learnings

- 1 件ごとに `Learning / Evidence / Impact` を作る
- 再利用可能で、SKILL 化する価値があるものだけ残す
- actionable な知見がなければ、変更なしで終了する

### 3. Route to Skill

- workspace `.github/skills/*/SKILL.md` の `name` と `description` を走査する
- 1 skill に明確にマッチする場合は、その workspace skill を反映先にする
- 複数にまたがる場合は最も specific な skill を優先し、残りは別候補として報告する
- 0 マッチの場合は新規 workspace skill 候補として提示し、明示承認なしに scaffold しない
- 新規候補の提案には、候補 skill 名、用途、既存 skill に収まらない理由、予定配置、最小 scaffold 内容、private mirror 可否を含める

### 4. Apply Local Changes

- safe-auto では、小〜中規模で workspace scope が明確な統合・更新だけ実行する
- 反映先は `SKILL.md`、`references/*`、必要最小の `scripts/*` / `assets/*` に限る
- hook、private mirror、外部公開、repo 同期、commit、push、`Sync-AndPush.ps1` は実行しない
- README は入口情報が古くなる場合だけ提案し、広い整理は別タスクにする

### 5. Verify

- workspace の変更ファイルを読み直す
- workspace `SKILL.md` の `name` がフォルダ名と一致しているか確認する
- frontmatter が `---` で閉じているか確認する
- secret / 顧客情報 / ローカル絶対パスらしき値が残っていないか確認する
- 追加より圧縮・統合が優先されているか確認する

## Report Format

```markdown
## Learnings
- {Learning}: {Evidence / Impact}

## Changes
- {更新した skill / file / 要点}

## Target Rationale
- {なぜその skill / file に入れたか}

## New Skill Proposal
- {新規作成が妥当な場合のみ、候補名 / 理由 / 予定配置 / scaffold 内容 / 承認待ち。なければ「なし」}

## Safety / Scope Check
- Workspace skill scope: PASS / FAIL
- Private mirror / commit / push: not executed
- Public sync / commit / push: not executed
- Sensitive data check: PASS / FAIL

## Next
- workspace で動作確認する
- workspace 反映済みの skill を private repo に移す場合: `mirror-workspace-skill-to-private` を対象 skill 名つきで実行
- private repo 反映済みで公開同期する場合: `sync-public-skills` を対象 skill 名つきで実行
```

Stop: 入力不足 / actionable な知見なし / scope 不一致 / Safety Gate 失敗 / 新規 skill 候補 / review-only。