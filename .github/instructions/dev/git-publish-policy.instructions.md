---
description: "Git の公開同期ポリシー（repo visibility、.github/.vscode の公開判断、公開済み時の対応）"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Git Publish Policy

公開同期、repo visibility、`.github` / `.vscode` の扱いを決めるときのルール。

## Decide Visibility First

- 最初に「この repo は `.github` を公開運用する目的か」を判定する。
- 判定できなければユーザーに質問する。
- 既定は非公開: `.github` / `.vscode` は通常追跡しない。

## Persist the Decision

- 初回確認結果は repo ローカルの `.hiker/repo-visibility-policy.json` に保存する。
- 参照キーは `origin URL` 推奨。
- 方針変更の明示指示がない限り、同じ質問を繰り返さない。
- `.hiker/` は `.gitignore` 対象にする。

## Non-Public Mode

- 追跡を止めるときは `git rm --cached` でインデックスから外し、`.gitignore` に `/.github/` `/.vscode/` `/.hiker/` を追加する。
- ローカル実ファイルは削除しない。
- 追跡するのは「リポジトリ公開に必要なファイル」だけにする。
- `.github` は workflow / automation / 運用上必要なメタデータのみ追跡し、不要な補助資料は追跡しない。

## If Already Published

- 通常は「今後同期しない」対応で十分（履歴は残す）。
- 履歴から削除するのはユーザーの明示指示があるときだけ。
- 履歴改変時はバックアップを取ってから `git filter-repo` + `force push` を実施し、共同開発者へ再同期手順を案内する。
- 必要ならシークレットを失効・再発行する。

## Default License Policy

- 新規公開 repo は原則 CC BY-NC-SA 4.0 LICENSE を採用する。
- 例外: `Agent-Skills` と `ghc_template`。