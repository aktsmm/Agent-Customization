---
applyTo: "**"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# グローバル（APPDATA）プロンプトのメタデータ運用

%APPDATA%/Code/User/prompts/ 配下の `*.prompt.md` / `*.agent.md` / `*.instructions.md` を編集・新規作成するときのルール。

## 必須: メタデータ（HTMLコメント）

以下のメタ情報ブロックは **必ずファイル先頭** に置き、削除・改変しない（プレフィックス安定性・同期/運用のため）。

- `syncToGlobal: true`（または省略）
- `author: ...`
- `repository: ...`
- `license: ...`
- `copyright: ...`

## `syncToGlobal` の付与ルール

### 付けてよい（= 同期対象）

- 汎用的で、他環境に持っていっても安全に動く
- **環境固有情報**（ローカルパス、テナントID、サブスクID、個人メール等）に依存しない
- **シークレットを含まない**（APIキー、トークン、接続文字列、パスワード等）

### 付けてはいけない（= ローカル専用）

次のいずれかに該当する場合は **`syncToGlobal: true` を書かない**（メタ情報ブロック自体は残しつつ、syncToGlobal 行だけ省略）。

- 環境固有の値を含む（例: Tenant/Subscription ID、Publisher、個人アカウント、ローカルの絶対パスなど）
- シークレット/認証情報を含む（例: API Key、Token、Password、Connection String）
- 顧客情報・社内情報など外部共有禁止の情報を含む

## シークレットの書き方（推奨）

直接書かずにプレースホルダ化する。

- 例: `AZURE_TENANT_ID=<set-in-env>` / `GITHUB_TOKEN=<set-in-env>`
- 参照が必要な場合は「環境変数/設定で渡す」旨を本文に書く（値は書かない）

## テンプレ

### 汎用プロンプト/エージェント（同期 OK）

```
---
description: ...   # prompt / agent の場合
applyTo: "**"      # instructions の場合
---

<!-- syncToGlobal: true -->
<!-- author: ... -->
<!-- repository: ... -->
<!-- license: ... -->
<!-- copyright: ... -->
```

### ローカル専用（同期 NG）

```
---
description: ...
---

<!-- author: ... -->
<!-- repository: ... -->
<!-- license: ... -->
<!-- copyright: ... -->
```