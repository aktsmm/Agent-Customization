---
name: sample
description: エージェント定義のテンプレート（VS Code / GitHub Copilot 対応）
tools: ["read", "edit", "search", "execute"]
# model: claude-sonnet-4-20250514  # オプション: 指定しない場合は選択中のモデルを使用
# target: vscode  # オプション: vscode | github-copilot | 両方（未指定時）
# infer: true  # オプション: サブエージェントとして使用可能か（デフォルト true）
# handoffs:  # オプション: 次のエージェントへの遷移
#   - label: Start Implementation
#     agent: implementation
#     prompt: Implement the plan outlined above.
#     send: false  # true にすると自動送信
---

# Sample Agent

## Role

あなたは [役割名] です。[対象] に対して [アクション] を行います。

## Goals

- [ゴール 1]
- [ゴール 2]

## Done Criteria

- [完了条件 1: 検証可能な形で記述]
- [完了条件 2]
- [検証方法: テスト/チェック/目視など]

## Permissions

- **Allowed**: ファイルの読み込み、編集、検索、ターミナル実行
- **Denied**: `git push`、ユーザーの許可なきファイル削除

## I/O Contract

- **Input**: [入力形式の説明]
- **Output**: [出力形式の説明]
- **IR Format**: （該当する場合）構造化データの仕様

## References

- [Git Rules](../instructions/dev/git.instructions.md)（存在する場合）
- [Terminal Rules](../instructions/dev/terminal.instructions.md)（存在する場合）
- [Security Rules](../instructions/core/security.instructions.md)（存在する場合）

## Workflow

1. **Plan**: ユーザーの要求を分析し、手順を提示する。
2. **Act**: 承認を得たら実行する。
3. **Verify**: 結果を確認する（テスト/チェック/目視）。

## Error Handling

- エラー発生時はエラーメッセージを分析し、修正を試みる
- 3 回連続で失敗した場合は人間に報告する
- 破壊的操作の前には必ず確認を求める

## Idempotency

- 既存ファイルの存在を確認してから操作する
- 重複処理を避けるため、状態を必ずチェックする

---

## YAML Frontmatter リファレンス

| プロパティ      | 型             | 説明                                                         |
| --------------- | -------------- | ------------------------------------------------------------ |
| `name`          | string         | エージェント名（未指定時はファイル名）                       |
| `description`   | string（必須） | エージェントの説明（Chat 入力欄に表示）                      |
| `tools`         | list/string    | 利用可能ツール（未指定時は全ツール）                         |
| `model`         | string         | 使用モデル（未指定時は選択中のモデル）                       |
| `target`        | string         | 対象環境: `vscode`, `github-copilot`, または両方（未指定時） |
| `infer`         | boolean        | サブエージェントとして推論可能か（デフォルト: true）         |
| `argument-hint` | string         | Chat 入力欄のヒントテキスト                                  |
| `handoffs`      | list           | 次のエージェントへの遷移定義                                 |
| `mcp-servers`   | object         | MCP サーバー設定（組織/エンタープライズレベルのみ）          |
| `metadata`      | object         | カスタムメタデータ（キー/値ペア）                            |

### tools プロパティ

```yaml
# 全ツール有効（デフォルト）
tools: ["*"]

# 特定ツールのみ
tools: ["read", "edit", "search"]

# MCP サーバーのツール
tools: ["github/*", "playwright/browser_snapshot"]

# ツール無効化
tools: []
```

**ツールエイリアス一覧**:

| エイリアス | 含まれるツール                       | 説明                     |
| ---------- | ------------------------------------ | ------------------------ |
| `execute`  | shell, bash, powershell              | ターミナルコマンド実行   |
| `read`     | Read, NotebookRead                   | ファイル読み込み         |
| `edit`     | Edit, MultiEdit, Write, NotebookEdit | ファイル編集             |
| `search`   | Grep, Glob                           | ファイル/テキスト検索    |
| `agent`    | custom-agent, Task                   | サブエージェント呼び出し |
| `web`      | WebSearch, WebFetch                  | Web 取得                 |
| `todo`     | TodoWrite                            | タスクリスト管理         |

### handoffs プロパティ

```yaml
handoffs:
  - label: Start Implementation # ボタン表示テキスト
    agent: implementation # 遷移先エージェント
    prompt: Implement the plan outlined above. # 送信プロンプト
    send: false # true で自動送信
```

---

## 参考リンク

- [Custom agents in VS Code](https://code.visualstudio.com/docs/copilot/customization/custom-agents)
- [Custom agents configuration - GitHub Docs](https://docs.github.com/en/copilot/reference/custom-agents-configuration)
- [awesome-copilot agents](https://github.com/github/awesome-copilot/tree/main/agents)
