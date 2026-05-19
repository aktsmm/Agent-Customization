---
description: "Node.js 環境設定（nvm 推奨、パッケージマネージャー）"
applyTo: "**/*.{js,ts,mjs,cjs,jsx,tsx},**/package.json"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
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
- lock file を削除して依存関係を作り直すのは最後の手段にする

## Execution Rules

- 依存導入や script 実行前に Node.js の version と package manager を確認する
- `package.json` の script と `engines` を尊重する
- 新しい依存を追加したら、必要なら audit や test で確認する

## Out of Scope Here

- nvm / fnm の導入手順
- package manager の詳細比較
- 長いセットアップ tutorial

それらは repo ドキュメントや onboarding 手順に分ける。
