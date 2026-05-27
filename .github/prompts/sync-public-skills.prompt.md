---
name: "sync-public-skills"
description: "workspace の確定済み SKILL を private skill repo に mirror / commit / push し、公開リポジトリへ同期する。Use when: workspace skill publish, skill private+public sync, sync public skills"
argument-hint: "対象 skill 名/workspace path、dirty skills、mode（safe-auto / review-only）"
agent: "agent"
tools: ["agent", "execute/runInTerminal"]
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# sync public skills

workspace `.github/skills/<skill>/` の確定済み差分を private skill repo に mirror / commit / push し、その後に公開リポジトリへ同期する。SKILL content authoring はこの prompt の責務ではない。

workspace で作成・修正した SKILL 変更を公開したい場合は、先に `retro-workspace-skill` で workspace を整え、その後にこの prompt で private / public の同期チェーンを完了する。

`Sync-AndPush.ps1` は `$ExcludeSkills` 以外の公開対象 skill 全体を同期する。ユーザー指定の skill は監査・説明の中心であり、script のコピー範囲を 1 skill に限定するものではない。

## When to Use

- 使う: workspace の既存 SKILL 変更を private skill repo と public repo にまとめて反映したいとき
- 使う: private skill repo にある既存 SKILL 差分を公開リポジトリへ同期したいとき
- 使う: 明示された skill、変更済み skill、または dirty skill を監査して publish したいとき
- 使う: `Sync-AndPush.ps1` 経由で public repo へ安全に同期したいとき
- 使わない: 学びを抽出して SKILL 本文へ入れたいとき。先に `retro-workspace-skill` を使う
- 使わない: `~/.copilot/skills` の個人 runtime SKILL を直接公開元にしたいとき
- 使わない: 新規 skill の設計や scaffold をしたいとき。まず確認して別 workflow に分ける

## Inputs / Modes

- Input: skill 名、workspace `.github/skills/<skill>/` パス、private repo の skill パス、`dirty skills` のいずれか
- Mode: `safe-auto` / `review-only` / `dry-run` / `プレビュー`。空欄は `safe-auto`

`review-only` / `dry-run` / `プレビュー` が明示された場合は、候補、監査、予定差分、commit message を提示して停止する。

## Paths

| 用途 | 解決方法 |
| --- | --- |
| workspace skill source | current workspace `.github/skills/<skill>/` |
| private skill repo | `SYNC_PUBLIC_SKILLS_PRIVATE_REPO` |
| public skill repo | `SYNC_PUBLIC_SKILLS_PUBLIC_REPO` |
| sync script | `SYNC_PUBLIC_SKILLS_SCRIPT` |

環境変数は Process scope を優先し、無ければ User scope を読む。値は prompt 本文や成果物に埋め込まない。

PowerShell で動的な環境変数を読むときは `$env:$name` を使わない。`(Get-Item "Env:$name" -ErrorAction SilentlyContinue).Value` か `[System.Environment]::GetEnvironmentVariable($name, 'User')` を使う。

## Scope Boundary

- この prompt は sync-chain-only。SKILL 本文の統合、置換、圧縮、学びの抽出はしない
- source of truth は current workspace の `.github/skills/<skill>/`。private skill repo は mirror target と publish source を兼ねる
- current workspace は Git 管理されていなくてもよい。Git 必須なのは private skill repo と public repo だけ
- public 対象判定の SSOT は `Sync-AndPush.ps1` の `$ExcludeSkills` 配列
- 新規 skill の公開追加、`$ExcludeSkills` 変更、公開可否不明の skill は確認で停止する
- README / index 更新が必要に見える場合は停止し、別 workflow へ回す。sync-only 実行中に内容編集しない
- `Sync-AndPush.ps1` は `-SkipDevPush` 付きで実行する
- Agent Skills Ninja などが作る未追跡の生成 JSON は、公開対象でないメタデータ / キャッシュ / 状態ファイルだと判定できる場合だけ cleanup してよい
- tracked JSON、selected skill 配下で公開 asset として管理している JSON、用途が曖昧な JSON は cleanup せず停止する

## Classification

| 分類 | 条件 | 動作 |
| --- | --- | --- |
| `primary` | ユーザーが明示した skill / 今回同期したい skill | 監査通過後に mirror / private commit / public sync |
| `synced-set` | `Sync-AndPush.ps1` が同期する `$ExcludeSkills` 以外の全公開対象 skill | private repo が clean で公開安全な場合だけ同期 |
| `blocked` | 公開可否不明、ライセンス不明、顧客/社内情報、意味変更が大きい | stage しない。理由を報告 |

primary は説明と監査の中心にする。safe-auto では private repo の公開対象 skill 全体が同期される前提で、unselected / blocked dirty skill が残る場合は停止する。

## Audit Gate

- 検出対象: secret、API key、password、client secret、connection string、refresh token、秘密鍵、token 形式、メールアドレス、実 ID、顧客/社内情報、個人環境値
- placeholder、ポリシー文、一般語だけでは除外しない
- 固有イベント名、個人ユーザー名入りパス、組織内でしか通じない文脈は blocked または修正依頼にする
- 監査が通らない場合は public sync をしない
- deterministic check として、workspace -> private の primary 差分と、private repo の primary / synced-set に対して secret scan、`git diff --check`、public diff 確認を行う

この prompt で監査中に内容修正が必要だと分かった場合は、原則として停止し、`retro-workspace-skill` での修正を提案する。

## Workflow

### 1. Resolve Paths

1. current workspace root と workspace `.github/skills/` の存在を確認する
2. 入力から target skill 名または workspace skill path を解決する
3. workspace が Git 管理かどうかを確認する。非 Git workspace でも継続してよい
4. override 環境変数を Process scope、User scope の順で読む
5. private repo、public repo、sync script を `Test-Path` で確認する
6. 未設定または存在しない場合だけ、既知 repo 名と script 名でローカル検索する
7. 0 件または複数件なら、検索範囲、候補、不足情報を報告して停止する

初期確認:

```powershell
Set-Location <workspace>
if (git rev-parse --is-inside-work-tree 2>$null) { git status --short } else { Get-ChildItem .github/skills -Directory | Select-Object -ExpandProperty Name }
Set-Location <private-skill-repo>
git branch --show-current
git remote get-url origin
git status --short
```

### 2. Select Skill Dirs

- 入力に workspace skill path または skill 名があれば、それを `primary` とする
- 入力が private repo の skill path のみなら、その同名 workspace skill を逆引きできる場合だけ `primary` とする
- `dirty skills` 指定または入力なしの場合は、workspace `.github/skills/` または private repo `.github/skills/` 配下の dirty skill 候補を列挙する
- workspace が Git 管理なら workspace 側の dirty 判定に `git status` を使ってよい
- workspace が非 Git 管理なら、workspace と private repo の skill directory 比較、入力で明示された skill、または更新時刻が近い skill を候補化してよい
- 入力なしで複数 dirty skill が見つかった場合は、safe-auto で広げず候補一覧を出して停止する
- 対象外 dirty skill は blocked または未採用として分離する。script が public 側へ流す可能性が残る場合は停止する
- workspace と private repo の folder 名、`SKILL.md` frontmatter の `name` が一致することを確認する
- 新規 skill directory の公開追加は確認で停止する

### 2.5 Cleanup Generated JSON

- dirty skill の判定前に、workspace と private repo の未追跡 JSON を確認する
- Agent Skills Ninja や類似ツールが落とした `.skill-meta.json`、install/export/cache/status/manifest 系の未追跡 JSON で、selected skill の公開 asset ではないと明確に判断できるものは削除してよい
- cleanup 対象は untracked files に限定する。tracked JSON や modified JSON は自動削除しない
- selected skill 配下の JSON でも、README / SKILL / scripts から参照される、または skill asset の可能性がある場合は削除せず停止する
- cleanup 後に dirty skill 候補を再評価する。生成 JSON だけが blocker だった場合は、そのまま後続へ進んでよい
- どの JSON を消したかは最終報告の `cleanup` に明記する

### 3. Compare Workspace To Private

- workspace skill と private skill の同じ相対パスだけを比較する
- private 側に同名 skill が無い場合は新規候補として停止する
- private 側に未確認の独自変更や衝突があれば停止し、diff plan を出す
- private 側がすでに workspace と一致していれば、mirror / private commit を skip して public sync から再開してよい

### 4. Audit and Confirm

- primary / synced-set の候補だけを監査する
- public-safe か、sync-only で完結するかを確認する
- `review-only` または停止条件に該当する場合は、予定差分と commit message を提示して停止する

### 5. Mirror And Commit Private Repo

- safe-auto では、監査済み primary skill directory だけを private repo に mirror する
- 削除は workspace 側に存在しない target skill 配下のファイルに限定し、unexpected deletion があれば停止する
- 対象 skill directory だけを明示的に stage する
- `git diff --cached --name-only` を確認し、selected skill dir 外が含まれたら停止する
- `git diff --cached --check` を実行し、whitespace/error があれば停止する
- commit message は `sync: mirror <skill> from workspace` 形式にする
- 既に対象差分が commit 済みなら、新規 commit なしで push 確認へ進んでよい
- commit 後は current branch と upstream/remote を確認し、曖昧でなければ private repo へ push する

### 6. Public Sync

必ず `Sync-AndPush.ps1` を使う。直接コピーで代替しない。

script 実行前に、private repo の公開対象 skill 全体が public-safe であることを確認する。unselected / blocked dirty skill が script 経由で public 側へ流れる可能性があれば停止する。

```powershell
<sync-script> -Message "sync: <skill summary>" -SkipDevPush
```

script が失敗したら、エラーを読み、原因を解消してから再実行する。手動コピーに切り替えない。

### 7. Verify Public Repo

- public repo のルート構造を確認する
- ルートに誤った `skills/` フォルダが作られていないか確認する
- public repo の直近 commit / diff stat が期待した skill dirs だけを含むことを確認する
- public repo の `git status --short` と直近 commit を確認する
- 必要に応じて公開 URL / remote URL を報告する
- 途中停止時は `workspace done / private done / public pending` のように再開位置を明示する

## Report Format

```markdown
## Summary
- {同期結果 1-3 行}

## Selected Skills
- primary: ...
- synced-set: ...
- blocked: ...

## Audit
- {監査結果、ヒット有無、除外理由}

## Private Sync
- mirror: ...
- private commit/push: ...

## Public Sync
- public sync: ...
- script: `Sync-AndPush.ps1 -SkipDevPush`

## Verify
- public repo structure: PASS / FAIL
- README/index: not edited / blocked（理由）
- resume state: ...
- cleanup: ...

## Not Done
- {未同期、blocked、retro-workspace-skill に戻すべき項目}
```

## Stop Conditions

- path ambiguity
- public safety audit failure
- new skill publication without confirmation
- `$ExcludeSkills` change needed
- unexpected deletion
- branch / remote ambiguity
- dirty changes outside selected skill dirs cannot be separated
- untracked generated JSON cannot be classified as safe cleanup or publish asset
- private repo is not clean and dirty changes would be included by `Sync-AndPush.ps1`
- content authoring is needed before sync

## Done Criteria

- primary / synced-set / blocked are classified before sync
- workspace skill is the source of truth for `primary`, or the stop reason is explicit
- workspace が非 Git 管理でも、source skill の特定方法が明示されている
- unsafe or unrelated dirty skill dirs cannot flow through `Sync-AndPush.ps1`
- workspace -> private compare completed before public sync
- audit passed before public sync
- private repo mirror / commit / push completed when needed, or skipped with reason
- public sync ran through `Sync-AndPush.ps1 -SkipDevPush`
- public repo structure was verified
- content authoring was not performed by this prompt
- publish source was private skill repo mirrored from workspace `.github/skills`