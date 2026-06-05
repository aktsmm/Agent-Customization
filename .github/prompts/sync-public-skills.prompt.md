---
name: "sync-public-skills"
description: "private skill repo の確定済み commit を remote private へ push し、必要なら isolated path で public repo へ同期する。Use when: private skill publish, private to public skill sync, sync public skills"
argument-hint: "対象 skill 名、private repo path（任意）、mode（safe-auto / review-only）"
agent: "agent"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# sync public skills

private skill repo の確定済み skill を remote private / public repo へ反映する。通常は broad sync script を使い、それが unsafe なときだけ `primary-only` で狭く同期する。SKILL 本文の authoring は行わない。

## When to Use

- 使う: private skill repo にある確定済み skill を remote private / public repo へ反映したいとき
- 使う: 対象 skill は clean だが、別 skill の未コミット差分のせいで broad sync が止まりやすいとき
- 使わない: SKILL 本文の統合、置換、圧縮、学びの抽出。先に `retro-private-skills` を使う
- 使わない: 新規 skill の設計や scaffold。別 workflow に分ける

## Mode

- 既定は `safe-auto`
- `review-only` / `dry-run` / `プレビュー` が明示された場合は、候補、監査、予定差分、commit message を提示して停止する

## Gates

- source of truth は private skill repo の `.github/skills/<skill>/`
- `SYNC_PUBLIC_SKILLS_PRIVATE_REPO` / `SYNC_PUBLIC_SKILLS_PUBLIC_REPO` / `SYNC_PUBLIC_SKILLS_SCRIPT` は Process scope 優先、無ければ User scope で解決する
- `.skill-meta.json` は local-only metadata として、dirty 判定、stage、push、public diff から除外する
- shared file として `.github/skills/README.md` と `.github/skills/assets/**` を別扱いする
- sync-only 実行中に README / assets / index / SKILL 本文の編集はしない
- branch / remote ambiguity、unexpected deletion、public safety audit failure、content authoring 必要時は停止する
- 手動コピーで public repo を直接触らず、script か一時 script variant で完結させる

## Sync Strategy

- 今回同期する明示 skill を `primary` とする
- 対象 skill が明示されている場合は、その skill の readiness と漏れ込みだけを先に確認する
- `primary` が clean かつ commit 済みなら、unselected dirty があっても即停止しない
- unselected dirty が public sync に漏れ得る場合は、main repo でそのまま実行せず isolated path を使う
- isolated path では、current HEAD の一時 clean worktree か同等の clean source を使い、public repo の `<primary>/` だけを更新する
- `primary-only` では他 skill directory の削除、shared file 更新、broad script の一括削除ロジックを使わない
- `primary` 以外が public diff に現れる、または一時環境を安全に準備できない場合だけ停止する

## Workflow

1. private repo、public repo、sync script を解決し、`primary`、branch / remote、local commits、dirty 状態を確認する
2. `primary` の readiness を監査し、`shared-dirty` と `unselected-dirty` が public sync に漏れるかを判定する
3. safe path を選ぶ
	- 直接実行: 漏れ込みが無い場合は `Sync-AndPush.ps1 -Message "sync: <skill summary>" -SkipDevPush`
	- isolated 実行: current HEAD の一時 clean source を使い、public repo の `<primary>/` だけを mirror する
4. private repo の current branch を remote private へ push し、public repo で `primary` のみが想定通り更新されたことを確認する

## Report

- Summary
- Primary / Synced Set
- Path Chosen
- Audit
- Private Sync
- Public Sync
- Verify
- Not Done
