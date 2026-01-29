# AGENTS

このリポジトリにあるすべての構造化エージェントをまとめた中央レジストリです。各エントリは `.github/agents` 配下のマニフェストへリンクしています。

> `sample.agent.md` が最小構成の例、`orchestrator.agent.md` がオーケストレーター構成の例です。テンプレ用途で増やすときはここに行を追加してください。

| エージェント名     | マニフェスト                             | 主な役割                                       |
| ------------------ | ---------------------------------------- | ---------------------------------------------- |
| Sample Agent       | `.github/agents/sample.agent.md`         | エージェント定義のテンプレート                 |
| Orchestrator Agent | `.github/agents/orchestrator.agent.md`   | サブエージェントを統括する司令塔の例           |
| Sync to Global     | `.github/agents/sync-to-global.agent.md` | instructions/prompts をグローバル設定に同期    |
| GHC Research       | `.github/agents/ghc-research.agent.md`   | GitHub Copilot/VS Code 関連の深い調査・レポート |

### グローバルエージェント（agents_sync/）

以下のエージェントは `@sync-to-global` でグローバル設定に同期し、全ワークスペースで使用可能になります。

| エージェント名    | ソース                                           | 主な役割                                   |
| ----------------- | ------------------------------------------------ | ------------------------------------------ |
| Workflow Designer | `.github/agents_sync/workflow-designer.agent.md` | エージェント設計・レビュー・改善を統合支援 |
| Deep Research     | `.github/agents_sync/DeepResearch.agent.md`      | 深い調査・引用付きレポート生成             |

**参照**: 詳細リファレンスは [agentic-workflow-guide](.github/skills/agentic-workflow-guide/SKILL.md) Skill を参照。

## 使い方

1. タスクに最も近いエージェントを選び、Copilot Chat で対応するマニフェストを読み込む（例: `/agent sample`）。
2. `.github/copilot-instructions.md` の共通ルールと、エージェント固有ガイドを組み合わせて使用する。
3. 新しいエージェントを追加する場合は、このテーブルに行を追加し、`.github/agents/` にマニフェストを配置する。

## 関連アセット

### 共有ガードレール

- [copilot-instructions.md](.github/copilot-instructions.md) — Copilot の振る舞い・回答スタイル・検証手順を定義（存在する場合）

### Instructions（ドメイン別ルール）

| ファイル                                                                                           | 説明                                                                         |
| -------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| [git.instructions.md](.github/instructions/dev/git.instructions.md)                                | Git コミット規約（Conventional Commits、Push 禁止、存在する場合）            |
| [terminal.instructions.md](.github/instructions/dev/terminal.instructions.md)                      | ターミナル操作規約（PowerShell 互換、破壊的操作の注意、存在する場合）        |
| [python.instructions.md](.github/instructions/dev/python.instructions.md)                          | Python 環境設定（仮想環境必須、uv 推奨、存在する場合）                       |
| [nodejs.instructions.md](.github/instructions/dev/nodejs.instructions.md)                          | Node.js 環境設定（nvm 推奨、パッケージマネージャー、存在する場合）           |
| [agent-design.instructions.md](.github/instructions/agents/agent-design.instructions.md)           | エージェント設計原則（単一責任、冪等性、オーケストレーション、存在する場合） |
| [security.instructions.md](.github/instructions/core/security.instructions.md)                     | セキュリティガイドライン（機密情報、外部 API、入力検証、存在する場合）       |
| [communication.instructions.md](.github/instructions/core/communication.instructions.md)           | コミュニケーションスタイル（結論ファースト、言語設定、存在する場合）         |
| [microsoft-docs.instructions.md](.github/instructions/integrations/microsoft-docs.instructions.md) | Microsoft 公式ドキュメント参照（MCP ツール活用、ソース明記、存在する場合）   |

### Prompts（再利用可能なプロンプト）

| ファイル                                                                                             | 説明                                    |
| ---------------------------------------------------------------------------------------------------- | --------------------------------------- |
| [create-workflow.prompt.md](.github/prompts/create-workflow.prompt.md)                               | エージェント/ワークフロー作成（統合版） |
| [review-agents-and-instructions.prompt.md](.github/prompts/review-agents-and-instructions.prompt.md) | エージェント・instructions のレビュー   |
| [plan-workflow.prompt.md](.github/prompts/plan-workflow.prompt.md)                                   | タスク実行計画                          |
| [design-workflow.prompt.md](.github/prompts/design-workflow.prompt.md)                               | ワークフロー設計                        |
| [debug-error.prompt.md](.github/prompts/debug-error.prompt.md)                                       | エラーデバッグ支援                      |
| [write-tests.prompt.md](.github/prompts/write-tests.prompt.md)                                       | テストコード生成                        |
| [gc_Commit.prompt.md](.github/prompts/gc_Commit.prompt.md)                                           | Git コミット（Push なし）               |
| [gcp_Commit_Push.prompt.md](.github/prompts/gcp_Commit_Push.prompt.md)                               | Git コミット＆プッシュ                  |
| [gpull.prompt.md](.github/prompts/gpull.prompt.md)                                                   | Git プル                                |
| [review-retrospective-learnings.prompt.md](.github/prompts/review-retrospective-learnings.prompt.md) | 学びを設計資産へ反映（ふりかえり）      |
| [review-session-export-md.prompt.md](.github/prompts/review-session-export-md.prompt.md)             | セッションエクスポート（Markdown）      |
| [export-log.prompt.md](.github/prompts/export-log.prompt.md)                                         | 汎用作業ログ（AI可読・構造化）          |
| [sample.prompt.md](.github/prompts/sample.prompt.md)                                                 | プロンプト作成用テンプレート            |

<!-- skill-ninja-START -->

## Installed Skills

The following skills are available in this workspace.

| Skill                                                                    | When to Use                                                                |
| ------------------------------------------------------------------------ | -------------------------------------------------------------------------- |
| [agentic-workflow-guide](.github/skills/agentic-workflow-guide/SKILL.md) | Use this skill when creating, reviewing, or updating agents and workflows: |

<!-- skill-ninja-END -->
