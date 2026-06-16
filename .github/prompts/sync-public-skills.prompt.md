---
name: "sync-public-skills"
description: "private skill repo の確定済み commit を remote private / EMU private / public repo へ反映する。Use when: private skill publish, private to public skill sync, EMU internal skill sync, sync public skills"
argument-hint: "対象 skill 名、private repo path（任意）、mode（safe-auto / review-only）、EMU同期要否"
agent: "agent"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# sync public skills

private skill repo の確定済み skill を remote private / EMU private / public repo へ反映する。通常は broad sync script を使い、それが unsafe なときだけ `primary-only` で狭く同期する。SKILL 本文の authoring は行わない。

## When to Use

- 使う: private skill repo にある確定済み skill を remote private / public repo へ反映したいとき
- 使う: private-only / MS 社内向け skill の更新差分を EMU private repo に反映したいとき
- 使う: 対象 skill は clean だが、別 skill の未コミット差分のせいで broad sync が止まりやすいとき
- 使わない: SKILL 本文の統合、置換、圧縮、学びの抽出。先に `retro-private-skills` を使う
- 使わない: 新規 skill の設計や scaffold。別 workflow に分ける

## Mode

- 既定は `safe-auto`
- `review-only` / `dry-run` / `プレビュー` が明示された場合は、候補、監査、予定差分、commit message を提示して停止する

## Gates

- source of truth は private skill repo の `.github/skills/<skill>/`（native skill）と `copilot-skills/{skills,m-skills}/`（`.copilot` 由来ミラー）
- `SYNC_PUBLIC_SKILLS_PRIVATE_REPO` / `SYNC_PUBLIC_SKILLS_PUBLIC_REPO` / `SYNC_PUBLIC_SKILLS_SCRIPT` は Process scope 優先、無ければ User scope で解決する
- EMU private sync 先は `SYNC_INTERNAL_SKILLS_EMU_REPO` を Process scope 優先、無ければ User scope で解決する。未設定なら repo URL / owner/name を確認する
- `.skill-meta.json` は local-only metadata として、dirty 判定、stage、push、public diff から除外する
- shared file として `.github/skills/README.md` と `.github/skills/assets/**` を別扱いする
- `ExcludeSkills` / private-only / internal-only / MS 社内向け skill は public sync から除外し、EMU private sync の候補として扱う
- sync-only 実行中に README / assets / index / SKILL 本文の編集はしない
- branch / remote ambiguity、unexpected deletion、public safety audit failure、content authoring 必要時は停止する
- 手動コピーで public repo を直接触らず、script か一時 script variant で完結させる

## EMU Private Sync Gate

- private-only / MS 社内向け skill に更新差分がある場合は、public sync とは別に「EMU 側にも反映するか」を確認する
- ユーザーが `all` を指定しても、public sync と EMU private sync を混同しない。public へ出してよい skill と EMU 限定 skill を分けて監査する
- EMU sync を実行する場合は、EMU repo の visibility が `PRIVATE` または `INTERNAL` であることを確認する。`PUBLIC` なら停止する
- EMU repo が user-owned private の場合、EMU 全員に自動公開されない。全員利用を求める場合は organization-owned `internal` repo が必要で、作成可否を確認する
- EMU sync 先にも secret / 顧客情報 / 個人メール / 具体 TPID / ローカル絶対パスを入れない。例は placeholder にする
- `gh repo view` / `gh api repos/...` で pull/push 権限が確認できるのに `git clone` が `Repository not found` になる場合は、repo 不在ではなく Git credential transport の不一致として扱う。visibility / permissions を再確認し、clone に固執せず Contents / Git Data API で tarball 取得、blob/tree/commit/ref 更新してよい

## Copilot-Skills Public Audit Gate

`copilot-skills/`（`.copilot` 由来ミラー）を public へ出す前に、skill 単位で 3 観点を監査し、除外対象を `Sync-AndPush.ps1 -ExcludeCopilotSkills` に渡す。判断は毎回ここで行い、script にハードコードしない。

- ①ライセンス: 第三者 Proprietary は除外する。Anthropic / Microsoft Scout ビルトイン（`docx` / `pptx` / `xlsx` 等、LICENSE.txt が複製・派生・サービス外保持を禁止）は public 不可。LICENSE 不明（`expense-report` / `receipt-ocr` / `loop` / `excalidraw` 等）は安全側で除外。Apache 2.0 等の再配布可能ライセンス（`web-artifacts-builder` 等）は LICENSE / NOTICE を保持して公開可
- ②DUP: 同名 skill が private repo `.github/skills/<skill>/` にある場合は、そちらを正として copilot-skills 側を public から除外する（二重公開防止）
- ③機密: ユーザー名、ローカル絶対パス、Tenant ID、顧客名、個人メールを含む skill は、一般化できないなら除外する。一般化済みの自作 skill（`export-session-log` / `m365-copilot-research` / `retro-private-skills` / `permission-max` 等）は公開可
- 既定ブラックリスト例: `docx,pptx,xlsx,expense-report,receipt-ocr,loop,excalidraw`（①②）＋ `.github/skills` と重複する skill（②）。新規 skill が増えたら上 3 観点で再判定してリストを更新する
- ブラックリストは `ExcludeSkills` 方式の踏襲。script は受け取った名前を機械的に除外するだけで、公開可否の判断はしない

## Sync Strategy

- 今回同期する明示 skill を `primary` とする
- 対象 skill が明示されている場合は、その skill の readiness と漏れ込みだけを先に確認する
- `primary` が clean かつ commit 済みなら、unselected dirty があっても即停止しない
- unselected dirty が public sync に漏れ得る場合は、main repo でそのまま実行せず isolated path を使う
- isolated path では、current HEAD の一時 clean worktree か同等の clean source を使い、public repo の `<primary>/` だけを更新する
- `primary-only` では他 skill directory の削除、shared file 更新、broad script の一括削除ロジックを使わない
- `primary` 以外が public diff に現れる、または一時環境を安全に準備できない場合だけ停止する

## Workflow

1. private repo、public repo、sync script、必要なら EMU repo を解決し、`primary`、branch / remote、local commits、dirty 状態を確認する
2. `primary` の readiness を監査し、`shared-dirty`、`private-only-dirty`、`unselected-dirty` が public / EMU sync に漏れるかを判定する。`copilot-skills/` を含む場合は Copilot-Skills Public Audit Gate の 3 観点でブラックリストを確定する
3. safe path を選ぶ
	- 直接実行: 漏れ込みが無い場合は `Sync-AndPush.ps1 -Message "sync: <skill summary>" -SkipDevPush -ExcludeCopilotSkills <監査で確定した除外名>`
	- isolated 実行: current HEAD の一時 clean source を使い、public repo の `<primary>/` だけを mirror する
	- EMU 実行: private-only skill を EMU private repo の該当 path へ mirror し、public repo に同 skill が出ていないことを確認する。Git transport が使えない場合は GitHub API 経路で単一 commit にまとめる
4. private repo の current branch を remote private へ push し、public repo と EMU repo で想定した skill のみが更新されたことを確認する

## Report

- Summary
- Primary / Synced Set
- Path Chosen
- Audit
- Private Sync
- EMU Private Sync
- Public Sync
- Verify
- Not Done
