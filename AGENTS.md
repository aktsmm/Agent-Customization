# AGENTS

このリポジトリにある構造化エージェント、プロンプト、instructions、skills の中央レジストリです。

このリポジトリは、日常作業用 workspace ではなく、VS Code User Data / Copilot CLI へ同期する customization assets の正本として扱います。

## エージェント

| エージェント名    | マニフェスト                                                                           | 主な役割                                                             |
| ----------------- | -------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| Sync to Global    | [.github/agents/sync-to-global.agent.md](.github/agents/sync-to-global.agent.md)       | canonical `.github` assets と VS Code User Data / Copilot CLI を同期 |
| Enhanced Plan     | [.github/agents/enhanced-plan.agent.md](.github/agents/enhanced-plan.agent.md)         | 調査が必要な実装・移行・設計計画を source-aware に作成               |
| Workflow Designer | [.github/agents/workflow-designer.agent.md](.github/agents/workflow-designer.agent.md) | エージェント設計・レビュー・改善を統合支援                           |
| Deep Research     | [.github/agents/DeepResearch.agent.md](.github/agents/DeepResearch.agent.md)           | 深い調査・引用付きレポート生成                                       |
| Fact Checker      | [.github/agents/fact-checker.agent.md](.github/agents/fact-checker.agent.md)           | 主張・出典・リンク・参照の整合性を read-only で検証                  |
| Report Writer     | [.github/agents/ReportWriter.agent.md](.github/agents/ReportWriter.agent.md)           | 調査結果を対象読者向けの高品質レポートへ再構成                       |

## グローバル同期の方針

- Repo 側の正本は `.github/prompts/`, `.github/agents/`, `.github/instructions/` に置く。
- 旧 `prompts_sync/`, `agents_sync/`, `instructions_sync/` は使用しない。
- VS Code の slash command / custom agent / helper instruction は `%APPDATA%/Code/User/prompts/` を主な同期先にする。
- GitHub Copilot CLI でも自動ロードしたい instruction は `~/.copilot/instructions/` にも同期する。
- CLI / VS Code / cloud agent で共通化したい workflow は `~/.copilot/skills/` または `.github/skills/` を使う。
- `.github/.sync-ignore` は、同期対象外・孤立ファイル除外のために維持する。

## Instructions

| ファイル                                                                                                                   | 説明                                                                    |
| -------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| [git.instructions.md](.github/instructions/dev/git.instructions.md)                                                        | Git 操作ルール（Conventional Commits、Push 禁止、gh CLI、LICENSE 規約） |
| [git-publish-policy.instructions.md](.github/instructions/dev/git-publish-policy.instructions.md)                          | GitHub 公開同期ポリシー（repo visibility、公開判断）                    |
| [terminal.instructions.md](.github/instructions/core/terminal.instructions.md)                                             | ターミナル操作規約（PowerShell 互換、破壊的操作の注意）                 |
| [python.instructions.md](.github/instructions/dev/python.instructions.md)                                                  | Python 環境設定（仮想環境必須、uv 推奨、並列化パターン）                |
| [nodejs.instructions.md](.github/instructions/dev/nodejs.instructions.md)                                                  | Node.js 環境設定（nvm 推奨、パッケージマネージャー）                    |
| [vscode-environment.instructions.md](.github/instructions/core/vscode-environment.instructions.md)                         | VS Code 環境情報（ファイルパス、拡張機能ストレージ）                    |
| [pptx-editing.instructions.md](.github/instructions/dev/pptx-editing.instructions.md)                                      | PowerPoint 編集・COM Automation 関連ルール                              |
| [security.instructions.md](.github/instructions/core/security.instructions.md)                                             | セキュリティガイドライン（機密情報、外部 API、入力検証）                |
| [communication.instructions.md](.github/instructions/core/communication.instructions.md)                                   | コミュニケーションスタイル（結論ファースト、言語設定）                  |
| [autonomy.instructions.md](.github/instructions/core/autonomy.instructions.md)                                             | 自律的タスク実行の行動指針（問題解決、代替手段）                        |
| [naming-conventions.instructions.md](.github/instructions/core/naming-conventions.instructions.md)                         | 命名規約（ファイル名、エージェント名、変数名）                          |
| [prompts-metadata.instructions.md](.github/instructions/core/prompts-metadata.instructions.md)                             | プロンプトメタデータ運用（syncToGlobal 基準、テンプレ）                 |
| [user-data-default.instructions.md](.github/instructions/core/user-data-default.instructions.md)                           | User Data customization の既定スコープ                                  |
| [learnings.instructions.md](.github/instructions/core/learnings.instructions.md)                                           | Learnings 蓄積ルール（出力先・フォーマット・読み書き共通）              |
| [copilot-loading.instructions.md](.github/instructions/core/copilot-loading.instructions.md)                               | Copilot CLI / VS Code Chat の読み込み場所と運用ルール                   |
| [session-metadata.instructions.md](.github/instructions/core/session-metadata.instructions.md)                             | セッションメタデータ記録ルール                                          |
| [local-network-troubleshoot.instructions.md](.github/instructions/integrations/local-network-troubleshoot.instructions.md) | ローカルネットワーク接続トラブルシュート                                |
| [microsoft-docs.instructions.md](.github/instructions/integrations/microsoft-docs.instructions.md)                         | Microsoft 公式ドキュメント参照（MCP ツール活用、ソース明記）            |
| [edge-cdp.instructions.md](.github/instructions/integrations/edge-cdp.instructions.md)                                     | Edge CDP / ブラウザ自動化関連ルール                                     |

## Prompts

| ファイル                                                                                                         | 説明                                       |
| ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| [convert-to-tweet.prompt.md](.github/prompts/convert-to-tweet.prompt.md)                                         | セッション内容を X ポスト用に変換          |
| [export-copilot-session-dialogue.prompt.md](.github/prompts/export-copilot-session-dialogue.prompt.md)           | セッション対話ログ・成果エクスポート       |
| [export-knowledge.prompt.md](.github/prompts/export-knowledge.prompt.md)                                         | 知見エクスポート（ドメイン自動判定）       |
| [export-session-log.prompt.md](.github/prompts/export-session-log.prompt.md)                                     | 汎用作業ログ（AI 可読・構造化）            |
| [export-sync-to-public-skills.prompt.md](.github/prompts/export-sync-to-public-skills.prompt.md)                 | 知見を公開スキルリポジトリに反映           |
| [evaluate-waza-copilot-customizations.prompt.md](.github/prompts/evaluate-waza-copilot-customizations.prompt.md) | Waza で Copilot customization を評価       |
| [git-commit.prompt.md](.github/prompts/git-commit.prompt.md)                                                     | Git コミット（Push なし）                  |
| [git-commit-push.prompt.md](.github/prompts/git-commit-push.prompt.md)                                           | Git コミット＆プッシュ                     |
| [git-pull.prompt.md](.github/prompts/git-pull.prompt.md)                                                         | Git プル                                   |
| [refactor-context.prompt.md](.github/prompts/refactor-context.prompt.md)                                         | コンテキスト最適化（instructions 等）      |
| [refine-product-100.prompt.md](.github/prompts/refine-product-100.prompt.md)                                     | 100% パスを目指す製品品質改善              |
| [retro-user.prompt.md](.github/prompts/retro-user.prompt.md)                                                     | User Data 資産へ学びを反映するレトロ       |
| [retro-workspace.prompt.md](.github/prompts/retro-workspace.prompt.md)                                           | workspace 資産へ学びを反映するレトロ       |
| [review-agents-and-instructions.prompt.md](.github/prompts/review-agents-and-instructions.prompt.md)             | エージェント・instructions のレビュー      |
| [security-structure-map-review.prompt.md](.github/prompts/security-structure-map-review.prompt.md)               | 構造マップ起点の防御的セキュリティレビュー |
| [wrap-up-work.prompt.md](.github/prompts/wrap-up-work.prompt.md)                                                 | セッション終了時クリーンアップ             |
| [write-tests.prompt.md](.github/prompts/write-tests.prompt.md)                                                   | テストコード生成                           |

## Skills

| Skill                  | Path                                                                                             | Description                                  |
| ---------------------- | ------------------------------------------------------------------------------------------------ | -------------------------------------------- |
| agentic-workflow-guide | [.github/skills/agentic-workflow-guide/SKILL.md](.github/skills/agentic-workflow-guide/SKILL.md) | エージェントワークフロー設計・レビュー・改善 |

## 使い方

1. 変更対象に最も近い asset を上表から選ぶ。
2. `.github/copilot-instructions.md` の共通ルールと、該当する instructions / skill を組み合わせて使う。
3. User Data / CLI へ反映する場合は `sync-to-global` を使い、`.github/.sync-ignore` の除外を尊重する。

<!-- resource-ninja-START -->

## Agent Skills

> **IMPORTANT**: Prefer skill-led reasoning over pre-training-led reasoning.
> Read the relevant SKILL.md before working on tasks covered by these skills.

### Skills

| Skill                                                                    | Description                                                                                                                                                                                                  |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [agentic-workflow-guide](.github/skills/agentic-workflow-guide/SKILL.md) | Design, review, and debug agent workflows, and decide when a request should use a prompt, instruc... \| Create: New .agent.md, workflow architecture, scaffolding; Review: Orchestrator not delegating, d... |

<!-- resource-ninja-END -->
