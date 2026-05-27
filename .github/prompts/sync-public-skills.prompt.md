---
name: "sync-public-skills"
description: "private skill repo の確定済み commit を remote private へ push し、Sync-AndPush.ps1 で公開リポジトリへ同期する。Use when: private skill publish, private to public skill sync, sync public skills"
argument-hint: "対象 skill 名、private repo path（任意）、mode（safe-auto / review-only）"
agent: "agent"
tools: ["agent", "execute/runInTerminal"]
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# sync public skills

private skill repo の確定済み差分を remote private へ push し、その後に public repo へ同期する。SKILL 本文の authoring は行わない。workspace の `.github/skills/**` は source of truth ではない。

## When to Use

- 使う: private skill repo に積まれた確定済み commit を remote private / public repo へ反映したいとき
- 使う: private skill repo にある既存 SKILL 差分を public repo へ同期したいとき
- 使わない: SKILL 本文の統合、置換、圧縮、学びの抽出。先に `retro-private-skills` を使う
- 使わない: 新規 skill の設計や scaffold。別 workflow に分ける

## Mode

- 既定は `safe-auto`
- `review-only` / `dry-run` / `プレビュー` が明示された場合は、候補、監査、予定差分、commit message を提示して停止する

## Core Rules

- source of truth は private skill repo の `.github/skills/<skill>/`
- workspace で skill を使うときは、public repo など GitHub 側の配布元から取得して使う
- private repo は `.github/skills/` 配置、public repo は repo 直下の skill directory 配置として扱う
- `SYNC_PUBLIC_SKILLS_PRIVATE_REPO` / `SYNC_PUBLIC_SKILLS_PUBLIC_REPO` / `SYNC_PUBLIC_SKILLS_SCRIPT` を Process scope 優先、無ければ User scope で解決する
- PowerShell の動的環境変数参照に `$env:$name` は使わない
- `.skill-meta.json` は local-only metadata として、dirty 判定、stage、push、public diff から除外する
- `Sync-AndPush.ps1` は必ず `-SkipDevPush` 付きで実行する
- sync-only 実行中に README / index / SKILL 本文の編集はしない
- 今回同期する明示 skill を `primary` とし、`Sync-AndPush.ps1` の `$ExcludeSkills` 以外を `synced-set` とみなす
- private repo に未コミット変更や対象外の dirty 差分がある場合は停止する
- 公開可否不明、branch / remote ambiguity、unexpected deletion、public safety audit failure、content authoring 必要時は停止する

## Fast Path

- 対象 skill が明示されている場合は、その skill の push readiness と監査を先に行う
- 探索を広げるのは、unselected dirty skill や未コミット変更が sync に混入する可能性の確認だけに限定する
- 手動コピーで public repo を直接触らず、private repo の push と script 実行で完結させる

## Workflow

1. private repo、public repo、sync script を解決し、branch / remote / local commits / dirty 状態を確認する
2. `primary` を private repo の `.github/skills/<skill>/` から確定し、`.skill-meta.json` を除外して未コミット変更を再評価する。selected / unselected を問わず dirty 差分があれば停止する
3. `primary` と必要なら `synced-set` を監査する。secret / sensitive scan、`git diff --check`、public-safe 判定を行う
4. private repo の current branch を remote private へ push する。push 対象 commit が無い場合はそのまま次へ進む
5. `Sync-AndPush.ps1 -Message "sync: <skill summary>" -SkipDevPush` を実行する
6. public repo で、期待した skill dir が更新されたこと、`git status` と直近 commit が妥当なことを確認する

## Report

- Summary
- Primary / Synced Set
- Audit
- Private Sync
- Public Sync
- Verify
- Not Done
