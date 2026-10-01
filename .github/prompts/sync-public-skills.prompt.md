---
name: "sync-public-skills"
description: "private skill repo の確定済み commit を remote private / EMU private / GIM internal / public repo へ反映する。Use when: private skill publish, private to public skill sync, EMU internal skill sync, GIM internal skill sync, sync public skills"
argument-hint: "対象 skill 名、範囲（primary-only / broad / diff-all / all）、dry-run、EMU/GIM同期要否"
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
- 対象 skill 名が明示された場合は `primary-only` とし、実行前に `Mode / Selected Skills / 選択外の public diff` を表示する。対象が曖昧なら「指定skillのみ（primary-only）」「確定済み全体（broad）」「差分があるもの全部（diff-all）」「未コミットも含む全部（all）」を提示し、会話の流れだけで primary を推測しない
- `diff-all` / 「差分があるもの全部」は、確定済み内容を同期先ごとに比較する範囲指定。`all`とは別で、dirtyのcommitや取り込みは行わずNot Doneへ残す。`review-only` / `dry-run`は引き続き実反映禁止。
- 依頼で指定された対象と、設定・過去承認で確定済みの宛先への通常同期は依頼自体を承認とする。実宛先・visibility・範囲を表示し、新規/曖昧な宛先、公開区分変更、破壊的削除、機密判断だけ確認する。`diff-all`だけで宛先を増やさない。
- `all` が指定された場合は、`primary` だけでなく **private repo 内の未コミット skill 差分も対象**にする。未コミットのまま残さず、skill 単位でコミットしてから sync する（後述 All Mode）

## All Mode（`all` 指定時の dirty 取り込み）

All Mode は先に private repo の `scripts/Commit-DirtySkills.ps1` をdry-runし、対象とNot Doneを確認する。意味・scopeが明確なskillだけ `-Apply`で個別commitしてから、cleanな同期scriptへ渡す。

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

- public / internal / denied / copilot-public / copilot-deniedの分類SSOTはprivate repoの `scripts/skill-distribution.json`。prompt本文やscriptへ現在の一覧を重複定義しない
- source of truth は private skill repo の `.github/skills/<skill>/`（native skill）と `copilot-skills/{skills,m-skills}/`（`.copilot` 由来ミラー）
- `dirty` は sync 必要性ではなく、未確定 authoring の gate として扱う。通常 sync の要否は private source path と public / internal / EMU destination path の content diff で判定する
- primary が明示されている場合、既定の確認範囲は primary とその同期経路に限定する。全 skill 棚卸し、全 duplicate、全 copilot-skills license audit は `all` / `broad` / `diff-all` / `audit` / `棚卸し` が明示された場合だけ行う
- `SYNC_PUBLIC_SKILLS_PRIVATE_REPO` / `SYNC_PUBLIC_SKILLS_PUBLIC_REPO` / `SYNC_PUBLIC_SKILLS_SCRIPT` は Process scope 優先、無ければ User scope で解決する
- EMU private sync 先は `SYNC_INTERNAL_SKILLS_EMU_REPO` を Process scope 優先、無ければ User scope で解決する。未設定なら repo URL / owner/name を確認する
- GIM internal 集約先は `SYNC_INTERNAL_SKILLS_GIM_REPO`（既定 `gim-home/yamapan-skills`、org-owned `internal`）を Process scope 優先、無ければ User scope で解決する
- `.skill-meta.json` は local-only metadata として、dirty 判定、stage、push、public diff から除外する
- shared file として `.github/skills/README.md`、`.github/skills/assets/**`、自動生成 index の `.github/skills/LICENSE` を別扱いする。broad sync 後に `LICENSE` だけが generated drift として残った場合は内容を確認し、意図どおりなら skill commit とは別に sync/index commit へ分ける
- skill を追加・削除した直後の broad sync は README freshness gate で停止する。`Update-PublicSkillsReadme.ps1` を実行し、生成差分を index commit として分けてから sync を再実行する
- `ExcludeSkills` / private-only / internal-only / MS 社内向け skill は public sync から除外し、EMU private sync の候補として扱う
- sync-only 実行中に README / assets / index / SKILL 本文の編集はしない
- remote不明、選択対象のdirty/未push/監査失敗、予期しない削除、authoringが必要なら停止する。primary-onlyの元checkoutのbehind/detached/選択外dirtyは、最新remote SHAと配布configを固定した読取snapshotで隔離できれば継続する。broadはbranch・clean・currentを維持する。
- 手動コピーで public repo を直接触らず、script か一時 script variant で完結させる

## EMU Private Sync Gate

- EMU private sync の既定セットは `skill-distribution.json` の `internalSkills` を使い、GIMと共有する

- private-only / MS 社内向け skill に更新差分がある場合は、EMU同期が未承認ならpublicとは別に確認する。初回にEMU/GIMを含む宛先・範囲を承認済みなら再確認しない
- ユーザーが `all` を指定しても、public sync と EMU private sync を混同しない。public へ出してよい skill と EMU 限定 skill を分けて監査する
- EMU sync を実行する場合は、EMU repo の visibility が `PRIVATE` または `INTERNAL` であることを確認する。`PUBLIC` なら停止する
- EMU repo が user-owned private の場合、EMU 全員に自動公開されない。全員利用を求める場合は organization-owned `internal` repo が必要で、作成可否を確認する
- EMU sync 先にも secret / 顧客情報 / 個人メール / 具体 TPID / ローカル絶対パスを入れない。例は placeholder にする
- `gh repo view` / `gh api repos/...` で pull/push 権限が確認できるのに `git clone` が `Repository not found` になる場合は、repo 不在ではなく Git credential transport の不一致として扱う。visibility / permissions を再確認し、clone に固執せず Contents / Git Data API で tarball 取得、blob/tree/commit/ref 更新してよい
- internal同期はconfigの全集合をfull mirrorする。subset指定は未選択Skillを削除し得るため停止する

## GIM Internal Sync Gate

MS 社内向け skill を enterprise 全員に「緩く公開」するための org-owned `internal` repo（既定 `gim-home/yamapan-skills`）への集約ゲート。`Sync-InternalSkills.ps1` が実装を担うが、「どれを internal へ出すか」の判断は毎回ここで行う。

- internal集約対象とaudience mapは `skill-distribution.json` の `internalSkills` をSSOTとする。新規skillは下3観点で再判定してconfigへ追加する
- 判定 3 観点: ①社内専用（public 不可だが社内なら有益） ②対象ロールまたは全社員に有益 ③匿名化済み（顧客実名 / TPID 実値 / 個人メール / ローカル絶対パスなし）
- internal 集約先の visibility が `INTERNAL` または `PRIVATE` であることを確認する。`PUBLIC` なら停止する
- internal skill は public sync の `ExcludeSkills` / `ExcludeCopilotSkills` に残し、public へ漏れないことを確認する（internal リストと public 除外リストは別管理）
- README.md は `Sync-InternalSkills.ps1` が毎回自動生成する。手書き編集しない（対象読者はスクリプト内の audience map、summary は各 SKILL.md の description がソース）
- push 前に機密スキャン（grep）を必須とし、ヒットがあれば停止する（誤検知確認済みのみ `-AllowSensitive`）
- EMU アカウント切替は script が finally で `aktsmm` へ復帰する。実行後に active アカウントを確認する

## Copilot-Skills Private Inventory Gate

`copilot-skills/`（`.copilot` 由来ミラー）は private inventory とし、license に関係なく public へ同期しない。`publicCopilotSkills` は空を維持し、inventory 全件を `deniedCopilotSkills` に分類する。`-IncludeCopilotSkills` / `-IncludeCopilotMSkills` は使わない。

- broad/allで新inventoryを検出したら分類保存まで停止する。primary-onlyではinventoryを読取・配布せず、未分類は保留として報告する。
- 同名 native skill が必要なら `.github/skills/<skill>/` へ別途 authoring し、native skill の public safety audit を通す。mirror の生コピーは公開しない
- public repo に `copilot-skills/` が存在したら broad sync で削除し、remote treeでも不在を確認する

## Sync Strategy

- `diff-all`の差分は、remote privateでは許可範囲の未送信commit、public/EMU/GIMでは確定済みsourceとのtracked path/blobで判定する。sourceはcleanに限定し、未追跡・生成物は除外する。差分ゼロの同期先では変更・commit・pushを行わない。dirtyが混入し得る経路は既存の隔離ルールに従う。
- `diff-all`でも分類・機密・削除ゲートは省略しない。publicは差分とshared fileの有無で既存のprimary-only/broadを選び、EMU/GIMは差分があればconfig全集合をfull mirrorする。`diff-all`はprompt上の選択肢であり、scriptへ同名の引数を渡さない。
- 今回同期する明示 skill を `primary` とする
- primary-only は `Sync-AndPush.ps1 -PrimarySkills <skill-name...>` を使う。一時コピー script を作らない
- 対象 skill が明示されている場合は、その skill の readiness、source/destination diff、漏れ込みだけを先に確認する。既定は `primary-only` とする
- primary-onlyはfetch後の`refs/remotes/origin/master`と実originのmaster SHAを照合し、そのSHAの選択skill・配布configを監査する。監査した完全SHAとorigin URLを`-SourceCommit`・`-ExpectedSourceOrigin`へ必須で渡し、途中でremoteが進めば再監査する。選択対象/configのdirty・未push、危険mode/pathは拒否し、選択外をcommit/pushしない。
- private未送信commitは先に範囲確認し、許可されたものだけ別段階でpushする。読取snapshotを使うprimary-onlyはprivateを自動pushしない。宛先との確定内容差分が0なら同期しない。
- `all` 指定時は unselected dirty を放置せず、All Mode の手順で skill 単位にコミットしてから sync する
- primary-onlyは検証済みSHA snapshotで元checkoutのbranch/dirtyを変更しない。runner不一致なら監査SHAのclean checkoutで実行し、Process scopeのsource変数を一時的にそのcheckoutへ向けてfinallyで戻す。broad/push経路はbranch・clean・current条件を満たす。
- `primary-only` では他 skill directory の削除、shared file 更新、broad script の一括削除ロジックを使わない。public / internal diff が selected primary destination path だけであることを検証する
- primary-onlyはcommit/push前に、生成物・local metadataを除いた監査sourceとpublic Git index/treeのmode・blob・pathを照合する。改行やclean filterで変換された場合はpushせず停止し、候補差分を自動再送しない。
- `primary-only`で選択外がpublic diffに現れる場合、または必要な一時環境を安全に準備できない場合は停止する

## New Skill Classification Gate (incident 2026-06-24 再発防止)

primary-onlyの分類ゲートは選択対象に限定する。未選択の未分類skillは公開せず保留とし、その分類修復を別skill同期の前提にしない。broad/allは全体の未分類があれば停止する。

対象内の未分類を検出した場合だけ、公開区分を推測せず`public-safe` / `internal-only` / `public-denied` / `今回は同期しない`を確認する。「今回は同期しない」はそのskillを選択から除外する一時保留で、永続denyや公開承認ではない。

ユーザーはその skill を以下のいずれかに分類してから再実行する:

- **public-safe**: configの `publicSkills` に追記する。追記前にlicense / DUP / secret auditを通す
- **internal-only**: configの `internalSkills` にname / audience / internalOnlyを追記する。public denylistへ自動統合される
- **public-denied**: configの `deniedSkills` に追記する。internalにも出さない

`-AllowUnknownSkills`で未知対象の公開をoverrideしない。同期する選択skillの分類はconfigへ保存済みであること。未知/denied/internalをpublicへコピーせず、全体修復が必要なら別workflowへ引き継ぐ。

## Workflow

1. private repo、public repo、sync script、必要なら EMU repo を解決し、`primary`、branch / remote、ahead/behind、dirty 状態を確認する
2. 選択対象のreadiness・分類・確定差分を確認し、選択外dirty/未分類は保留する。broad/allだけ全体分類・shared/inventoryゲートを実施する。機密・license・削除・ミラー検証は同期する範囲で省略しない。
2.5. `all` 指定時は `Commit-DirtySkills.ps1` のdry-run→`-Apply`でskill単位にcommitする。skill以外のdirtyはNot Doneに残し、同期scriptへ渡さない
3. safe path を選ぶ
	- diff-all: 承認済みで差分がある同期先だけを実行する。public同期不要でEMU/GIMに差分がある場合は、`Sync-InternalSkills.ps1`を対象repo・config全集合で直接実行し、public処理を経由しない
	- primary-only 実行: `Sync-AndPush.ps1 -PrimarySkills <skill-name...> -SourceCommit <audited-full-sha> -ExpectedSourceOrigin <approved-origin-url> -Message "sync: <skill summary>" -SkipDevPush`。監査した内容と実行sourceを結び付け、選択外・shared/inventoryは変更しない。
	- broad 実行: `Sync-AndPush.ps1 -Message "sync: <summary>" -SkipDevPush`。public-safe native 全体と shared files を mirror し、public の `copilot-skills/` は削除する
	- EMU 実行: private-only skill を EMU private repo の該当 path へ mirror し、public repo に同 skill が出ていないことを確認する。`Sync-AndPush.ps1 -SyncEmu [-EmuDryRun]` を使う。Git transport が使えない場合は GitHub API 経路で単一 commit にまとめる
	- GIM internal 実行: MS 社内向け skill を org-owned `internal` repo（`gim-home/yamapan-skills`）へ集約する場合は `Sync-AndPush.ps1 -SyncInternal [-InternalDryRun]` を使う。README は自動再生成される
4. publicのmirror hash・remote到達、EMU/GIMのremote treeを検証する。Missing/Mismatch/Extra 0、実行checkout clean・ahead 0を完了条件とし、選択外の元checkoutは変更しない。
5. dirty→Retro、未push→private範囲確認、最近commit済みpublic-safeの内容差分→public syncを最大3件の次候補にする。件数だけで実行を追加せず、明示保留は`-ExcludeFollowUpSkills`で尊重する。未分類は分類/監査候補、private/internalは公開候補にしない。

- 検証は変更規模に合わせる。実測では同期suiteの時間は隔離やfetchでなくfixture再作成とpwsh起動を伴う統合テストが支配する（約100秒）。小変更は対象テストと`-ExcludeTag Integration`、runner/backend変更だけ全件を1回実行する。

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
- Next Suggestions（提案のみ。対象と宛先を増やさない）
