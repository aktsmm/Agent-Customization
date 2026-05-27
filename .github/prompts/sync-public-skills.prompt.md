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

workspace `.github/skills/<skill>/` の確定済み差分を private skill repo に mirror / commit / push し、その後に public repo へ同期する。SKILL 本文の authoring は行わない。

## When to Use

- 使う: workspace の既存 SKILL 変更を private / public repo へ反映したいとき
- 使う: private skill repo にある既存 SKILL 差分を public repo へ同期したいとき
- 使わない: SKILL 本文の統合、置換、圧縮、学びの抽出。先に `retro-workspace-skill` を使う
- 使わない: 新規 skill の設計や scaffold。別 workflow に分ける

## Mode

- 既定は `safe-auto`
- `review-only` / `dry-run` / `プレビュー` が明示された場合は、候補、監査、予定差分、commit message を提示して停止する

## Core Rules

- source of truth は current workspace の `.github/skills/<skill>/`
- current workspace は非 Git でもよいが、private repo と public repo は Git 必須
- `SYNC_PUBLIC_SKILLS_PRIVATE_REPO` / `SYNC_PUBLIC_SKILLS_PUBLIC_REPO` / `SYNC_PUBLIC_SKILLS_SCRIPT` を Process scope 優先、無ければ User scope で解決する
- PowerShell の動的環境変数参照に `$env:$name` は使わない
- `.skill-meta.json` は local-only metadata として、dirty 判定、compare、mirror、stage、public diff から除外する
- `Sync-AndPush.ps1` は必ず `-SkipDevPush` 付きで実行する
- sync-only 実行中に README / index / SKILL 本文の編集はしない
- 今回同期する明示 skill を `primary` とし、`Sync-AndPush.ps1` の `$ExcludeSkills` 以外を `synced-set` とみなす
- 公開可否不明、未採用 dirty skill、branch / remote ambiguity、unexpected deletion、public safety audit failure、content authoring 必要時は停止する

## Fast Path

- 対象 skill が明示されている場合は、その skill の compare と監査を先に行う
- 探索を広げるのは、unselected / blocked dirty skill が public 側へ流れる可能性の確認だけに限定する
- 手動コピーで public repo を直接触らず、private への targeted mirror と script 実行で完結させる

## Workflow

1. workspace root、`.github/skills/`、private repo、public repo、sync script を解決し、branch / remote / dirty 状態を確認する
2. `primary` を確定し、`.skill-meta.json` を除外して dirty skill を再評価する。未採用 dirty skill が public 側へ流れうるなら停止する
3. workspace と private の同名 skill を同じ相対パスで比較する。private 側に無い場合や衝突がある場合は停止する
4. `primary` と必要なら `synced-set` を監査する。secret / sensitive scan、`git diff --check`、public-safe 判定を行う
5. `primary` だけを private repo に mirror し、selected files だけを stage して `sync: mirror <skill> from workspace` で commit / push する
6. `Sync-AndPush.ps1 -Message "sync: <skill summary>" -SkipDevPush` を実行する
7. public repo で、誤った `skills/` ルートが無いこと、期待した skill dir が更新されたこと、`git status` と直近 commit が妥当なことを確認する

## Report

- Summary
- Selected Skills
- Audit
- Private Sync
- Public Sync
- Verify
- Not Done
