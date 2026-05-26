---
name: "sync-public-skills"
description: "private skill repo の既存 SKILL を監査し、公開リポジトリへ同期する。Use when: sync public skills, skill publish, SKILL 公開同期。workspace mirror や SKILL 本文編集は行わない"
argument-hint: "対象 skill 名/パス、dirty skills、mode（safe-auto / review-only）"
agent: "agent"
tools: ["agent", "execute/runInTerminal"]
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# sync public skills

private skill repo の `.github/skills/<skill>/` に commit / push 済み、または同期準備済みの差分を監査し、公開リポジトリへ同期する。SKILL content authoring と workspace mirror はこの prompt の責務ではない。

workspace で作成・修正した SKILL 変更を公開したい場合は、先に `retro-workspace-skill` で workspace を整え、`mirror-workspace-skill-to-private` で private skill repo に反映する。この prompt はその後段だけを扱う。

`Sync-AndPush.ps1` は `$ExcludeSkills` 以外の公開対象 skill 全体を同期する。ユーザー指定の skill は監査・説明の中心であり、script のコピー範囲を 1 skill に限定するものではない。

## When to Use

- 使う: private skill repo にある既存 SKILL 差分を公開リポジトリへ同期したいとき
- 使う: 明示された skill、変更済み skill、または dirty skill を監査して publish したいとき
- 使う: `Sync-AndPush.ps1` 経由で public repo へ安全に同期したいとき
- 使う: `mirror-workspace-skill-to-private` 後に、private repo 側の確定済み差分を public repo へ同期したいとき
- 使わない: 学びを抽出して SKILL 本文へ入れたいとき。先に `retro-workspace-skill` を使う
- 使わない: workspace `.github/skills` だけにある変更を直接公開したいとき。先に `mirror-workspace-skill-to-private` を実行する
- 使わない: `~/.copilot/skills` の個人 runtime SKILL を直接公開元にしたいとき
- 使わない: 新規 skill の設計や scaffold をしたいとき。まず確認して別 workflow に分ける

## Inputs / Modes

- Input: skill 名、skill パス、`dirty skills`、または private repo の対象差分
- Mode: `safe-auto` / `review-only` / `dry-run` / `プレビュー`。空欄は `safe-auto`

`review-only` / `dry-run` / `プレビュー` が明示された場合は、候補、監査、予定差分、commit message を提示して停止する。

## Paths

| 用途 | 解決方法 |
| --- | --- |
| private skill repo | `SYNC_PUBLIC_SKILLS_PRIVATE_REPO` |
| public skill repo | `SYNC_PUBLIC_SKILLS_PUBLIC_REPO` |
| sync script | `SYNC_PUBLIC_SKILLS_SCRIPT` |

環境変数は Process scope を優先し、無ければ User scope を読む。値は prompt 本文や成果物に埋め込まない。

PowerShell で動的な環境変数を読むときは `$env:$name` を使わない。`(Get-Item "Env:$name" -ErrorAction SilentlyContinue).Value` か `[System.Environment]::GetEnvironmentVariable($name, 'User')` を使う。

## Scope Boundary

- この prompt は public-sync-only。SKILL 本文の統合、置換、圧縮、学びの抽出、workspace mirror はしない
- publish source は private skill repo の `.github/skills/` のみ。workspace `.github/skills/` は直接読まない
- public 対象判定の SSOT は `Sync-AndPush.ps1` の `$ExcludeSkills` 配列
- 新規 skill の公開追加、`$ExcludeSkills` 変更、公開可否不明の skill は確認で停止する
- README / index 更新が必要に見える場合は停止し、別 workflow へ回す。sync-only 実行中に内容編集しない
- private repo 側の commit / push は `mirror-workspace-skill-to-private` の責務。`Sync-AndPush.ps1` は `-SkipDevPush` 付きで実行する

## Classification

| 分類 | 条件 | 動作 |
| --- | --- | --- |
| `primary` | ユーザーが明示した skill / 今回同期したい skill | 監査通過後に public sync |
| `synced-set` | `Sync-AndPush.ps1` が同期する `$ExcludeSkills` 以外の全公開対象 skill | private repo が clean で公開安全な場合だけ同期 |
| `blocked` | 公開可否不明、ライセンス不明、顧客/社内情報、意味変更が大きい | stage しない。理由を報告 |

primary は説明と監査の中心にする。safe-auto では private repo の公開対象 skill 全体が同期される前提で、unselected / blocked dirty skill が残る場合は停止する。

## Audit Gate

- 検出対象: secret、API key、password、client secret、connection string、refresh token、秘密鍵、token 形式、メールアドレス、実 ID、顧客/社内情報、個人環境値
- placeholder、ポリシー文、一般語だけでは除外しない
- 固有イベント名、個人ユーザー名入りパス、組織内でしか通じない文脈は blocked または修正依頼にする
- 監査が通らない場合は public sync をしない
- deterministic check として、primary と synced-set に対して secret scan、`git diff --check`、public diff 確認を行う

この prompt で監査中に内容修正が必要だと分かった場合は、原則として停止し、`retro-workspace-skill` での修正と `mirror-workspace-skill-to-private` での private mirror を提案する。

## Workflow

### 1. Resolve Paths

1. override 環境変数を Process scope、User scope の順で読む
2. private repo、public repo、sync script を `Test-Path` で確認する
3. 未設定または存在しない場合だけ、既知 repo 名と script 名でローカル検索する
4. 0 件または複数件なら、検索範囲、候補、不足情報を報告して停止する

初期確認:

```powershell
Set-Location <private-skill-repo>
git branch --show-current
git status --short
```

### 2. Select Skill Dirs

- 入力が workspace `.github/skills` のパスや current workspace のみの変更を指している場合は停止し、`mirror-workspace-skill-to-private` を実行してから戻るよう案内する
- 入力に skill 名またはパスがあれば、それを `primary` とする
- `dirty skills` 指定または入力なしの場合は、private repo の `.github/skills/` 配下の dirty skill と synced-set を列挙する
- 入力なしで複数 dirty skill が見つかった場合は、safe-auto で広げず候補一覧を出して停止する
- 対象外 dirty skill は blocked または未採用として分離する。script が public 側へ流す可能性が残る場合は停止する
- 新規 skill directory の公開追加は確認で停止する

### 3. Audit and Confirm

- primary / synced-set の候補だけを監査する
- public-safe か、sync-only で完結するかを確認する
- `review-only` または停止条件に該当する場合は、予定差分と commit message を提示して停止する

### 4. Public Sync

必ず `Sync-AndPush.ps1` を使う。直接コピーで代替しない。

script 実行前に、private repo の公開対象 skill 全体が public-safe であることを確認する。unselected / blocked dirty skill が script 経由で public 側へ流れる可能性があれば停止する。private repo 側の commit / push はこの prompt では行わない。

```powershell
<sync-script> -Message "sync: <skill summary>" -SkipDevPush
```

script が失敗したら、エラーを読み、原因を解消してから再実行する。手動コピーに切り替えない。

### 5. Verify Public Repo

- public repo のルート構造を確認する
- ルートに誤った `skills/` フォルダが作られていないか確認する
- public repo の直近 commit / diff stat が期待した skill dirs だけを含むことを確認する
- public repo の `git status --short` と直近 commit を確認する
- 必要に応じて公開 URL / remote URL を報告する

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

## Sync
- private commit/push: not executed / already done
- public sync: ...
- script: `Sync-AndPush.ps1 -SkipDevPush`

## Verify
- public repo structure: PASS / FAIL
- README/index: not edited / blocked（理由）
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
- private repo is not clean and dirty changes would be included by `Sync-AndPush.ps1`
- content authoring is needed before sync
- requested changes exist only in workspace `.github/skills`（`mirror-workspace-skill-to-private` へ handoff）

## Done Criteria

- primary / synced-set / blocked are classified before sync
- unsafe or unrelated dirty skill dirs cannot flow through `Sync-AndPush.ps1`
- audit passed before public sync
- private repo commit / push was not performed by this prompt
- public sync ran through `Sync-AndPush.ps1 -SkipDevPush`
- public repo structure was verified
- content authoring was not performed by this prompt
- publish source was private skill repo, not workspace `.github/skills`