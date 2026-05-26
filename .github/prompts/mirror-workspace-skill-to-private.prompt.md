---
name: "mirror-workspace-skill-to-private"
description: "workspace の .github/skills にある既存 SKILL 差分を private skill repo へ mirror し、private repo で commit / push する。Use when: skill private mirror, workspace skill to private, SKILL private 反映"
argument-hint: "対象 skill 名/パス、mode（safe-auto / review-only）"
agent: "agent"
tools: ["agent", "execute/runInTerminal"]
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# mirror workspace skill to private

workspace `.github/skills/<skill>/` の確定済み差分を private skill repo の同名 skill directory に mirror する。SKILL content authoring と public sync は行わない。

## When to Use

- 使う: workspace で更新済みの既存 skill を private skill repo に反映したいとき
- 使う: `retro-workspace-skill` 実行後、private repo に同じ差分を揃えたいとき
- 使う: private repo 側で selected skill directory だけ commit / push したいとき
- 使わない: SKILL 本文の学び抽出、統合、置換、圧縮をしたいとき。先に `retro-workspace-skill` を使う
- 使わない: public repo へ同期したいとき。private repo 反映後に `sync-public-skills` を使う
- 使わない: `~/.copilot/skills` の個人 runtime SKILL を直接同期したいとき
- 使わない: 新規 skill の公開可否が未判断のとき。確認で停止する

## Inputs / Modes

- Input: skill 名、workspace `.github/skills/<skill>/` パス、または private mirror 対象の差分
- Mode: `safe-auto` / `review-only` / `dry-run` / `プレビュー`。空欄は `safe-auto`

`review-only` / `dry-run` / `プレビュー` が明示された場合は、候補、監査、予定差分、commit message を提示して停止する。

## Paths

| 用途 | 解決方法 |
| --- | --- |
| workspace skill source | current workspace `.github/skills/<skill>/` |
| private skill repo | `SYNC_PUBLIC_SKILLS_PRIVATE_REPO` |

環境変数は Process scope を優先し、無ければ User scope を読む。値は prompt 本文や成果物に埋め込まない。

PowerShell で動的な環境変数を読むときは `$env:$name` を使わない。`(Get-Item "Env:$name" -ErrorAction SilentlyContinue).Value` か `[System.Environment]::GetEnvironmentVariable($name, 'User')` を使う。

## Scope Boundary

- この prompt は mirror-only。SKILL 本文の統合、置換、圧縮、学びの抽出はしない
- source は current workspace の `.github/skills/<skill>/` のみ
- target は private skill repo の `.github/skills/<skill>/` のみ
- public repo、`Sync-AndPush.ps1`、User Data prompt、`~/.copilot/skills` は対象外
- `git add -A` で repo 全体を stage しない。対象 skill directory だけ明示的に stage する
- 新規 skill、公開可否不明、README / index 更新が必要に見える場合は確認で停止する

## Classification

| 分類 | 条件 | 動作 |
| --- | --- | --- |
| `primary` | ユーザーが明示した既存 skill | 監査通過後に mirror / commit / push |
| `unselected` | 対象外の workspace dirty skill | stage / mirror しない |

対象 skill が複数ある場合は safe-auto で広げず、候補一覧を出して停止する。

## Audit Gate

- 検出対象: secret、API key、password、client secret、connection string、refresh token、秘密鍵、token 形式、メールアドレス、実 ID、顧客/社内情報、個人環境値
- placeholder、ポリシー文、一般語だけでは除外しない
- 固有イベント名、個人ユーザー名入りパス、組織内でしか通じない文脈は blocked または修正依頼にする
- 監査が通らない場合は mirror / commit / push しない
- deterministic check として、対象差分に対して secret scan、`git diff --check`、selected dirs 外の staged file 確認を行う

この prompt で内容修正が必要だと分かった場合は停止し、`retro-workspace-skill` に戻す。

## Workflow

### 1. Resolve Paths

1. 現在の workspace root を確認する
2. workspace `.github/skills/` の存在を確認する
3. private skill repo を `SYNC_PUBLIC_SKILLS_PRIVATE_REPO` から解決する
4. private repo の `.github/skills/` の存在を確認する
5. 0 件または複数候補で曖昧なら、検索範囲、候補、不足情報を報告して停止する

初期確認:

```powershell
Set-Location <workspace>
git status --short
Set-Location <private-skill-repo>
git branch --show-current
git remote get-url origin
git status --short
```

### 2. Select Skill Dir

- 入力に skill 名またはパスがあれば、それを `primary` とする
- 入力なしの場合は workspace `.github/skills/` 配下の dirty skill を列挙する
- workspace と private repo の folder 名、`SKILL.md` frontmatter の `name` が一致することを確認する
- private 側に同名 skill が無い場合は新規候補として停止する

### 3. Compare and Audit

- workspace skill と private skill の同じ相対パスだけを比較する
- mirror 対象は対象 skill directory 配下に限定する
- private 側に未確認の独自変更や衝突があれば停止し、diff plan を出す
- primary の差分だけを監査する

### 4. Mirror to Private Repo

- safe-auto では、監査済み primary skill directory だけ mirror する
- 削除は workspace 側に存在しない target skill 配下のファイルに限定し、unexpected deletion があれば停止する
- public repo、README / index、script、他 skill directory は変更しない

### 5. Commit Private Repo

- 対象 skill directory だけを明示的に stage する
- stage 後に `git diff --cached --name-only` を確認し、selected skill dir 外が含まれたら停止する
- `git diff --cached --check` を実行し、whitespace/error があれば停止する
- commit message は `sync: mirror <skill> from workspace` 形式にする
- 既に対象差分が commit 済みなら、新規 commit なしで push 確認へ進んでよい
- commit 後は current branch と upstream/remote を確認し、曖昧でなければ private repo へ push する
- push 後に `git status --short` と `git log -1 --oneline` で対象 commit を確認する

## Report Format

```markdown
## Summary
- {mirror 結果 1-3 行}

## Selected Skill
- primary: ...
- unselected: ...

## Audit
- {監査結果、ヒット有無、除外理由}

## Mirror
- workspace source: ...
- private target: ...
- file set: ...

## Commit
- private commit/push: ...
- staged files: selected skill directory only / FAIL

## Next
- public repo へ同期する場合: `sync-public-skills` を対象 skill 名つきで実行
- content authoring が必要な場合: `retro-workspace-skill` に戻す
```

## Stop Conditions

- path ambiguity
- no workspace `.github/skills`
- no private repo `.github/skills`
- ambiguous skill selection
- new skill without confirmation
- audit failure
- private side has unrelated dirty changes in target dir
- unexpected deletion
- branch / remote ambiguity
- diff includes files outside selected skill dir
- content authoring is needed before mirror

## Done Criteria

- selected skill dir is classified as primary / unselected, or stopped by Stop Conditions
- mirror source is workspace `.github/skills/<skill>/`
- mirror target is private repo `.github/skills/<skill>/`
- audit passed before mirror / commit / push
- selected skill dir only is staged and committed when needed
- private repo push is confirmed when performed
- public sync was not executed
- content authoring was not performed by this prompt