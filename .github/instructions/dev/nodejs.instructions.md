---
description: "Node.js 環境設定（nvm 推奨、パッケージマネージャー）"
applyTo: "**/*.{js,ts,mjs,cjs,jsx,tsx},**/package.json"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Node.js Environment Instructions

Node.js では、セットアップ手順より project behavior rule を優先する。

## Core Rules

- Node.js はバージョン管理ツール経由で使う
- repo に `.nvmrc`、`.node-version`、`package.json#engines` があればそれを尊重する
- lock file がある project では、その package manager を優先し、混在させない
- `node_modules/` はコミットしない
- 開発用依存は原則として local dependency に置き、グローバル install を常用しない

## Package Manager Rules

- `package-lock.json` があるなら npm、`pnpm-lock.yaml` があるなら pnpm、`yarn.lock` があるなら yarn を優先する
- automation や CI 相当の実行では、`ci` や `--frozen-lockfile` 相当で再現性を守る
- 管理端末で公開 registry への直接通信が禁止されている場合は、承認済みの registry 設定を使い、遮断先を `--registry` で強制したり TLS 検証を無効にしたりしない
- 公開 OSS の lockfile 更新後は、`resolved` の社内専用 URL 混入と integrity を検査し、その lockfile で clean install と full audit を確認する。ローカルで証明できない場合は承認済み hosted CI で生成・検証する
- lock file を削除して依存関係を作り直すのは最後の手段にする

## Execution Rules

- 依存導入や script 実行前に Node.js の version と package manager を確認する
- `package.json` の script と `engines` を尊重する
- `npm exec <tool>` が未導入の package を対話的に追加しようとしたら、検証目的では package script か既存の local binary へ切り替え、依存追加の明示依頼なしに承認しない。
- 新しい依存を追加したら、必要なら audit や test で確認する

## Out of Scope Here

- nvm / fnm の導入手順
- package manager の詳細比較
- 長いセットアップ tutorial

それらは repo ドキュメントや onboarding 手順に分ける。
