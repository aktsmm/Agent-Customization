# AGENTS

このリポジトリにあるすべての構造化エージェントをまとめた中央レジストリです。各エントリは `.github/agents` 配下のマニフェストへリンクしています。

> `sample.agent.md` が最小構成の例、`orchestrator.agent.md` がオーケストレーター構成の例です。テンプレ用途で増やすときはここに行を追加してください。

| エージェント名     | マニフェスト                             | 主な役割                                                           |
| ------------------ | ---------------------------------------- | ------------------------------------------------------------------ |
| Sample Agent       | `.github/agents/sample.agent.md`         | エージェント定義のテンプレート                                     |
| Orchestrator Agent | `.github/agents/orchestrator.agent.md`   | サブエージェントを統括する司令塔の例                               |
| Sync to Global     | `.github/agents/sync-to-global.agent.md` | instructions/prompts をグローバル設定に同期（`.sync-ignore` 対応） |

### グローバルエージェント（agents_sync/）

以下のエージェントは `@sync-to-global` でグローバル設定に同期し、全ワークスペースで使用可能になります。

| エージェント名    | ソース                                           | 主な役割                                       |
| ----------------- | ------------------------------------------------ | ---------------------------------------------- |
| Workflow Designer | `.github/agents_sync/workflow-designer.agent.md` | エージェント設計・レビュー・改善を統合支援     |
| Deep Research     | `.github/agents_sync/DeepResearch.agent.md`      | 深い調査・引用付きレポート生成                 |
| Report Writer     | `.github/agents_sync/ReportWriter.agent.md`      | 調査結果を対象読者向けの高品質レポートへ再構成 |

**参照**: 詳細リファレンスは [agentic-workflow-guide](.github/skills/agentic-workflow-guide/SKILL.md) Skill を参照。

## 使い方

1. タスクに最も近いエージェントを選び、Copilot Chat で対応するマニフェストを読み込む（例: `/agent sample`）。
2. `.github/copilot-instructions.md` の共通ルールと、エージェント固有ガイドを組み合わせて使用する。
3. 新しいエージェントを追加する場合は、このテーブルに行を追加し、`.github/agents/` にマニフェストを配置する。

## 関連アセット

### 共有ガードレール

- [copilot-instructions.md](.github/copilot-instructions.md) — Copilot の振る舞い・回答スタイル・検証手順を定義（存在する場合）

### Instructions（ドメイン別ルール）

| ファイル                                                                                                | 説明                                                                    |
| ------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| [git.instructions.md](.github/instructions_sync/dev/git.instructions.md)                                | Git 操作ルール（Conventional Commits、Push 禁止、gh CLI、LICENSE 規約） |
| [terminal.instructions.md](.github/instructions_sync/dev/terminal.instructions.md)                      | ターミナル操作規約（PowerShell 互換、破壊的操作の注意）                 |
| [python.instructions.md](.github/instructions_sync/dev/python.instructions.md)                          | Python 環境設定（仮想環境必須、uv 推奨、並列化パターン）                |
| [nodejs.instructions.md](.github/instructions_sync/dev/nodejs.instructions.md)                          | Node.js 環境設定（nvm 推奨、パッケージマネージャー）                    |
| [security.instructions.md](.github/instructions_sync/core/security.instructions.md)                     | セキュリティガイドライン（機密情報、外部 API、入力検証）                |
| [communication.instructions.md](.github/instructions_sync/core/communication.instructions.md)           | コミュニケーションスタイル（結論ファースト、言語設定）                  |
| [autonomy.instructions.md](.github/instructions_sync/core/autonomy.instructions.md)                     | 自律的タスク実行の行動指針（問題解決、代替手段）                        |
| [naming-conventions.instructions.md](.github/instructions_sync/core/naming-conventions.instructions.md) | 命名規約（ファイル名、エージェント名、変数名）                          |
| [prompts-metadata.instructions.md](.github/instructions_sync/core/prompts-metadata.instructions.md)     | プロンプトメタデータ運用（syncToGlobal 基準、テンプレ）                 |
| [learnings.instructions.md](.github/instructions_sync/core/learnings.instructions.md)                   | Learnings 蓄積ルール（出力先・フォーマット・読み書き共通）              |
| [microsoft-docs.instructions.md](.github/instructions_sync/integrations/microsoft-docs.instructions.md) | Microsoft 公式ドキュメント参照（MCP ツール活用、ソース明記）            |
| [vscode-environment.instructions.md](.github/instructions_sync/dev/vscode-environment.instructions.md)  | VS Code 環境情報（ファイルパス、拡張機能ストレージ）                    |

### Prompts（再利用可能なプロンプト）

| ファイル                                                                                                    | 説明                                    |
| ----------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| [create-workflow.prompt.md](.github/prompts/create-workflow.prompt.md)                                      | エージェント/ワークフロー作成（統合版） |
| [review-agents-and-instructions.prompt.md](.github/prompts_sync/review-agents-and-instructions.prompt.md)   | エージェント・instructions のレビュー   |
| [code-fix-error.prompt.md](.github/prompts_sync/code-fix-error.prompt.md)                                   | エラー修正（原因特定→最小修正→確認）    |
| [code-review.prompt.md](.github/prompts_sync/code-review.prompt.md)                                         | コードレビュー＋自動修正                |
| [debug-error.prompt.md](.github/prompts_sync/debug-error.prompt.md)                                         | エラーデバッグ支援                      |
| [write-tests.prompt.md](.github/prompts_sync/write-tests.prompt.md)                                         | テストコード生成                        |
| [git-commit.prompt.md](.github/prompts_sync/git-commit.prompt.md)                                           | Git コミット（Push なし）               |
| [git-commit-push.prompt.md](.github/prompts_sync/git-commit-push.prompt.md)                                 | Git コミット＆プッシュ                  |
| [git-pull.prompt.md](.github/prompts_sync/git-pull.prompt.md)                                               | Git プル                                |
| [review-retrospective-learnings.prompt.md](.github/prompts_sync/review-retrospective-learnings.prompt.md)   | 学びを設計資産へ反映（ふりかえり）      |
| [export-session-log.prompt.md](.github/prompts_sync/export-session-log.prompt.md)                           | 汎用作業ログ（AI可読・構造化）          |
| [export-copilot-session-dialogue.prompt.md](.github/prompts_sync/export-copilot-session-dialogue.prompt.md) | セッション対話ログ・成果エクスポート    |
| [export-knowledge.prompt.md](.github/prompts_sync/export-knowledge.prompt.md)                               | 知見エクスポート（ドメイン自動判定）    |
| [export-sync-to-public-skills.prompt.md](.github/prompts_sync/export-sync-to-public-skills.prompt.md)       | 知見を公開スキルリポジトリに反映        |
| [wrap-up-work.prompt.md](.github/prompts_sync/wrap-up-work.prompt.md)                                       | セッション終了時クリーンアップ          |
| [convert-to-tweet.prompt.md](.github/prompts_sync/convert-to-tweet.prompt.md)                               | セッション内容をXポスト用に変換         |
| [refactor-context.prompt.md](.github/prompts_sync/refactor-context.prompt.md)                               | コンテキスト最適化（instructions等）    |
| [sample.prompt.md](.github/prompts/sample.prompt.md)                                                        | プロンプト作成用テンプレート            |

<!-- skill-ninja-START -->

## Agent Skills (Compressed Index)

> **IMPORTANT**: Prefer skill-led reasoning over pre-training-led reasoning.
> Read the relevant SKILL.md before working on tasks covered by these skills.

### Skills Index

| Skill                                                                    | Path                     | Description                                                                                          |
| ------------------------------------------------------------------------ | ------------------------ | ---------------------------------------------------------------------------------------------------- |
| [agentic-workflow-guide](.github/skills/agentic-workflow-guide/SKILL.md) | `agentic-workflow-guide` | Create, review, and update Prompt and agents and workflows. Covers 5 workflow patterns, runSubage... |

<!-- skill-ninja-END -->
