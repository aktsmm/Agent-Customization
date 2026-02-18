# `.github/instructions` ディレクトリ

エージェントが読み込むドメイン別ガイドラインを置く場所。

> **Note**: このリポジトリでは、実際の instruction ファイルは **`instructions_sync/`** に配置されています。
> `instructions_sync/` は `@sync-to-global` エージェントでグローバル設定に同期するための専用フォルダです。
> ワークスペース固有の instructions を追加する場合は、この `instructions/` ディレクトリに配置してください。

## ディレクトリ構成（instructions_sync/ の実態）

```
instructions_sync/
├── core/                                  # コア・共通ルール
│   ├── autonomy.instructions.md           # 自律的タスク実行の行動指針
│   ├── communication.instructions.md      # コミュニケーションスタイル
│   ├── naming-conventions.instructions.md # 命名規約
│   └── security.instructions.md           # セキュリティガイドライン
├── dev/                                   # 開発ツール系
│   ├── git.instructions.md                # Git操作規約
│   ├── terminal.instructions.md           # ターミナル操作規約
│   ├── python.instructions.md             # Python環境設定
│   └── nodejs.instructions.md             # Node.js環境設定
└── integrations/                          # 外部連携系
    └── microsoft-docs.instructions.md     # MS Docs MCP連携
```

## カテゴリ説明

| カテゴリ        | 目的                       | 追加例                        |
| --------------- | -------------------------- | ----------------------------- |
| `core/`         | 全エージェント共通のルール | レビュー規約、命名規則        |
| `dev/`          | 開発ツール操作のルール     | Docker, npm, pytest           |
| `integrations/` | 外部サービス連携           | Azure CLI, GitHub API, OpenAI |

## カスタマイズ

- ファイル名は `<topic>.instructions.md` のようにしておくと分かりやすい。
- コーディング規約やドキュメント方針など、共有したいルールを簡潔にまとめる。
- runSubagent の利用条件や「軽量タスクはメインで対応する」といったナレッジもここに書いておけば、各エージェントから参照できる。

新しいインストラクションを追加する場合は、適切なカテゴリフォルダに配置してね。
