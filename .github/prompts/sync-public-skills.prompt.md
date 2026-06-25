---
name: "sync-public-skills"
description: "private skill repo の確定済み commit を remote private / EMU private / GIM internal / public repo へ反映する。Use when: private skill publish, private to public skill sync, EMU internal skill sync, GIM internal skill sync, sync public skills"
argument-hint: "対象 skill 名、private repo path（任意）、mode（safe-auto / review-only）、EMU/GIM同期要否"
agent: "agent"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# sync public skills

private skill repo の確定済み skill を remote private / EMU private / GIM internal / public repo へ反映する。通常は broad sync script を使い、それが unsafe なときだけ `primary-only` で狭く同期する。SKILL 本文の authoring は行わない。

## When to Use

- 使う: private skill repo にある確定済み skill を remote private / public repo へ反映したいとき
- 使う: private-only / MS 社内向け skill の更新差分を EMU private repo や GIM internal repo に反映したいとき
- 使う: 対象 skill は clean だが、別 skill の未コミット差分のせいで broad sync が止まりやすいとき
- 使わない: SKILL 本文の統合、置換、圧縮、学びの抽出。先に `retro-private-skills` を使う
- 使わない: 新規 skill の設計や scaffold。別 workflow に分ける

## Mode

- 既定は `safe-auto`
- `review-only` / `dry-run` / `プレビュー` が明示された場合は、候補、監査、予定差分、commit message を提示して停止する
- `all` が指定された場合は、`primary` だけでなく **private repo 内の未コミット skill 差分も対象**にする。未コミットのまま残さず、skill 単位でコミットしてから sync する（後述 All Mode）

## All Mode（`all` 指定時の dirty 取り込み）

All Mode は dirty を次の分類で扱う。

| 対象 | 動作 | 理由 / 注意 |
| --- | --- | --- |
| skill content dirty | skill 単位で stage / 個別コミットする（`feat|fix|docs(<skill>): ...`） | 対象は private repo の `.github/skills/<skill>/**` と `copilot-skills/{skills,m-skills}/<skill>/**`。複数 skill を 1 コミットに混ぜない |
| `.skill-meta.json` untracked | stage せず削除可 | local-only metadata |
| `.skill-meta.json` tracked | Gate 停止 | tracked file は自動削除しない |
| shared file（README / assets） | 従来どおり All Mode の dirty skill intake から除外 | skill content と混ぜない |
| skill 以外の dirty（scripts、設定、無関係ファイル、`/memories/**`） | stage せず Not Done に列挙 | mixed commit 防止 |
| public-safe skill | commit 後に public sync 候補 | skill ごとに sync 先を判定する |
| internal-only / private-only skill | commit 後に EMU/GIM 候補、public から除外 | public へ漏らさない |
| secret / 顧客名 / 個人メール / 具体 TPID / ローカル絶対パスを含む skill | commit は可、public sync から除外。一般化できないものは EMU/GIM も確認停止 | 漏えい防止 |
| 大規模削除 / 意味変更 / scope 不明な差分 | その skill だけ自動コミットせず確認停止 | 安全判断が必要 |

## Gates

- source of truth は private skill repo の `.github/skills/<skill>/`（native skill）と `copilot-skills/{skills,m-skills}/`（`.copilot` 由来ミラー）
- `dirty` は sync 必要性ではなく、未確定 authoring の gate として扱う。通常 sync の要否は private source path と public / internal / EMU destination path の content diff で判定する
- primary が明示されている場合、既定の確認範囲は primary とその同期経路に限定する。全 skill 棚卸し、全 duplicate、全 copilot-skills license audit は `all` / `broad` / `audit` / `棚卸し` が明示された場合だけ行う
- `SYNC_PUBLIC_SKILLS_PRIVATE_REPO` / `SYNC_PUBLIC_SKILLS_PUBLIC_REPO` / `SYNC_PUBLIC_SKILLS_SCRIPT` は Process scope 優先、無ければ User scope で解決する
- EMU private sync 先は `SYNC_INTERNAL_SKILLS_EMU_REPO` を Process scope 優先、無ければ User scope で解決する。未設定なら repo URL / owner/name を確認する
- GIM internal 集約先は `SYNC_INTERNAL_SKILLS_GIM_REPO`（既定 `gim-home/yamapan-skills`、org-owned `internal`）を Process scope 優先、無ければ User scope で解決する
- `.skill-meta.json` は local-only metadata として、dirty 判定、stage、push、public diff から除外する
- shared file として `.github/skills/README.md`、`.github/skills/assets/**`、自動生成 index の `.github/skills/LICENSE` を別扱いする。broad sync 後に `LICENSE` だけが generated drift として残った場合は内容を確認し、意図どおりなら skill commit とは別に sync/index commit へ分ける
- `ExcludeSkills` / private-only / internal-only / MS 社内向け skill は public sync から除外し、EMU private sync の候補として扱う
- sync-only 実行中に README / assets / index / SKILL 本文の編集はしない
- branch / remote ambiguity、unexpected deletion、public safety audit failure、content authoring 必要時は停止する
- 手動コピーで public repo を直接触らず、script か一時 script variant で完結させる

## EMU Private Sync Gate

- EMU private sync の既定セット（SSOT）は GIM internal と同じ `InternalSkills` を使う。現行既定: `c360-operations`, `d365-expense-sorter`, `m365-copilot-research`, `esxp-labor-entry`

- private-only / MS 社内向け skill に更新差分がある場合は、public sync とは別に「EMU 側にも反映するか」を確認する
- ユーザーが `all` を指定しても、public sync と EMU private sync を混同しない。public へ出してよい skill と EMU 限定 skill を分けて監査する
- EMU sync を実行する場合は、EMU repo の visibility が `PRIVATE` または `INTERNAL` であることを確認する。`PUBLIC` なら停止する
- EMU repo が user-owned private の場合、EMU 全員に自動公開されない。全員利用を求める場合は organization-owned `internal` repo が必要で、作成可否を確認する
- EMU sync 先にも secret / 顧客情報 / 個人メール / 具体 TPID / ローカル絶対パスを入れない。例は placeholder にする
- `gh repo view` / `gh api repos/...` で pull/push 権限が確認できるのに `git clone` が `Repository not found` になる場合は、repo 不在ではなく Git credential transport の不一致として扱う。visibility / permissions を再確認し、clone に固執せず Contents / Git Data API で tarball 取得、blob/tree/commit/ref 更新してよい

## GIM Internal Sync Gate

MS 社内向け skill を enterprise 全員に「緩く公開」するための org-owned `internal` repo（既定 `gim-home/yamapan-skills`）への集約ゲート。`Sync-InternalSkills.ps1` が実装を担うが、「どれを internal へ出すか」の判断は毎回ここで行う。

- internal 集約対象の既定セット（SSOT）: `c360-operations`, `d365-expense-sorter`, `m365-copilot-research`, `esxp-labor-entry`。新規 skill は下 3 観点で再判定して追加する
- 判定 3 観点: ①社内専用（public 不可だが社内なら有益） ②対象ロールまたは全社員に有益 ③匿名化済み（顧客実名 / TPID 実値 / 個人メール / ローカル絶対パスなし）
- internal 集約先の visibility が `INTERNAL` または `PRIVATE` であることを確認する。`PUBLIC` なら停止する
- internal skill は public sync の `ExcludeSkills` / `ExcludeCopilotSkills` に残し、public へ漏れないことを確認する（internal リストと public 除外リストは別管理）
- README.md は `Sync-InternalSkills.ps1` が毎回自動生成する。手書き編集しない（対象読者はスクリプト内の audience map、summary は各 SKILL.md の description がソース）
- push 前に機密スキャン（grep）を必須とし、ヒットがあれば停止する（誤検知確認済みのみ `-AllowSensitive`）
- EMU アカウント切替は script が finally で `aktsmm` へ復帰する。実行後に active アカウントを確認する

## Copilot-Skills Public Audit Gate

`copilot-skills/`（`.copilot` 由来ミラー）を broad sync で public へ出す前に、skill 単位で 3 観点を監査し、除外対象を `Sync-AndPush.ps1 -ExcludeCopilotSkills` に渡す。primary-only では primary の分類と漏れ込み確認だけを行い、対象外 skill の公開可否を毎回再判定しない。判断は必要時にここで行い、script にハードコードしない。

- ①ライセンス: 第三者 Proprietary は除外する。Anthropic / Microsoft Scout ビルトイン（`docx` / `pptx` / `xlsx` 等、LICENSE.txt が複製・派生・サービス外保持を禁止）は public 不可。LICENSE 不明（`expense-report` / `receipt-ocr` / `loop` / `excalidraw` 等）は安全側で除外。Apache 2.0 等の再配布可能ライセンス（`web-artifacts-builder` 等）は LICENSE / NOTICE を保持して公開可
- ②DUP: 同名 skill が private repo `.github/skills/<skill>/` にある場合は、そちらを正として copilot-skills 側を public から除外する（二重公開防止）
- ③機密: ユーザー名、ローカル絶対パス、Tenant ID、顧客名、個人メールを含む skill は、一般化できないなら除外する。一般化済みの自作 skill（`export-session-log` / `m365-copilot-research` / `retro-private-skills` / `permission-max` 等）は公開可
- 既定ブラックリスト例: `docx,pptx,xlsx,expense-report,receipt-ocr,loop,excalidraw`（①②）＋ `.github/skills` と重複する skill（②）。新規 skill が増えたら上 3 観点で再判定してリストを更新する
- ブラックリストは `ExcludeSkills` 方式の踏襲。script は受け取った名前を機械的に除外するだけで、公開可否の判断はしない

## Sync Strategy

- 今回同期する明示 skill を `primary` とする
- 対象 skill が明示されている場合は、その skill の readiness、source/destination diff、漏れ込みだけを先に確認する。既定は `primary-only` とする
- `primary` が clean かつ commit 済みなら、unselected dirty があっても即停止しない。dirty が primary path にある場合は未確定 authoring とみなし、`all` 指定がない限り `retro-private-skills` へ戻す
- private repo が clean で ahead の場合は、sync 前に remote private へ push してよい。private repo が clean かつ remote と同期済みでも、destination と content diff があれば sync 対象にする
- `all` 指定時は unselected dirty を放置せず、All Mode の手順で skill 単位にコミットしてから sync する
- unselected dirty が public sync に漏れ得る場合は、main repo でそのまま実行せず isolated path を使う
- isolated path では、current HEAD の一時 clean worktree か同等の clean source を使い、public repo の `<primary>/` だけを更新する
- `primary-only` では他 skill directory の削除、shared file 更新、broad script の一括削除ロジックを使わない。public / internal diff が selected primary destination path だけであることを検証する
- `primary` 以外が public diff に現れる、または一時環境を安全に準備できない場合だけ停止する

## New Skill Classification Gate (incident 2026-06-24 再発防止)

private repo に未分類の skill（`$KnownPublicSkills` / `$DefaultInternalSkills` / `$HardDeniedSkills` のどこにもない folder）がある状態で sync を走らせない。`Sync-AndPush.ps1` は Step 0.5 で `Invoke-NewSkillGate` を実行し、未分類 skill を検出したら `exit 2` で強制停止する。

ユーザーはその skill を以下のいずれかに分類してから再実行する:

- **public-safe**: `$KnownPublicSkills` に追記する。追記前に Copilot-Skills Public Audit Gate の 3 観点（license / DUP / secret）を通す
- **internal-only**: `$DefaultInternalSkills` に追記する。`$HardDeniedSkills` へは自動マージされ、GIM/EMU 同期対象になる
- **public-denied**: `$HardDeniedSkills` に追記する。internal にも出さない skill。

例外したいときだけ、認識した上で `-AllowUnknownSkills` を付けて public-safe として同期させる。面倒だからでは使わず、ケースごとに分類を保存する。

## Workflow

1. private repo、public repo、sync script、必要なら EMU repo を解決し、`primary`、branch / remote、ahead/behind、dirty 状態を確認する
2. `primary` の readiness と source/destination content diff を確認し、`shared-dirty`、`private-only-dirty`、`unselected-dirty` が public / EMU sync に漏れるかを判定する。broad sync で `copilot-skills/` を含む場合だけ Copilot-Skills Public Audit Gate の 3 観点でブラックリストを確定する
2.5. `all` 指定時は、All Mode に従い未コミットの skill 差分を skill 単位でコミットする（skill 以外の dirty は除外し Not Done に回す）。コミット後に各 skill の public/EMU/GIM 振り分けを監査する
3. safe path を選ぶ
	- 直接実行: 漏れ込みが無い場合は `Sync-AndPush.ps1 -Message "sync: <skill summary>" -SkipDevPush -ExcludeCopilotSkills <監査で確定した除外名>`
	- isolated 実行: current HEAD の一時 clean source を使い、public repo の `<primary>/` だけを mirror する
	- EMU 実行: private-only skill を EMU private repo の該当 path へ mirror し、public repo に同 skill が出ていないことを確認する。`Sync-AndPush.ps1 -SyncEmu [-EmuDryRun]` を使う。Git transport が使えない場合は GitHub API 経路で単一 commit にまとめる
	- GIM internal 実行: MS 社内向け skill を org-owned `internal` repo（`gim-home/yamapan-skills`）へ集約する場合は `Sync-AndPush.ps1 -SyncInternal [-InternalDryRun]` を使う。README は自動再生成される
4. private repo の current branch を remote private へ push し、public repo / EMU repo / GIM internal repo で想定した skill のみが更新されたことを確認する。`all` のときは public-safe skill は public へ、default internal set は EMU/GIM にも流す

## Report

- Summary
- Primary / Synced Set
- Path Chosen
- Audit
- Private Sync
- EMU Private Sync
- GIM Internal Sync
- Public Sync
- Verify
- Not Done
