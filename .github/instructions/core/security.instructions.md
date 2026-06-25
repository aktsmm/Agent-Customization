---
description: "セキュリティガイドライン（機密情報、外部API、入力検証）"
applyTo: "**"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Security Instructions

コード生成・ファイル操作・外部サービス利用時の最小セキュリティルール。

## Secrets

- API キー、パスワード、トークン、接続文字列をコードやドキュメントに書かない。
- `.env`、秘密鍵、証明書、シークレットを Git に追加しない。
- 機密値は環境変数や Key Vault / GitHub Secrets / Secret Manager などから取得する。
- `.gitignore` に `.env*`, `*.pem`, `*.key`, `secrets/` などを含める。

## Dependencies

- 新しい外部ライブラリは、ライセンスと既知脆弱性を確認する。
- 必要なら `npm audit`、`pnpm audit`、`pip-audit`、`dotnet list package --vulnerable` を使う。
- リスクの高い依存を追加する場合は、代替案や必要性を説明する。

## External APIs

- API 権限は最小スコープにする。
- レート制限がある API ではリトライやバックオフを考慮する。
- ユーザー向けエラーにスタックトレース、内部 URL、秘密情報を出さない。

## Input and Paths

- ユーザー入力や外部データは、SQL / command / XSS injection を想定して検証する。
- ファイルパスはディレクトリトラバーサルを防ぐ。`..` や絶対パスの扱いに注意する。
- 生成物にローカル絶対パスや個人情報を埋め込まない。

## Git Safety

- 明示指示なしに push、force push、履歴改変をしない。
- 公開リポジトリへ同期する前に、秘密情報・顧客情報・個人環境情報が含まれないか確認する。
