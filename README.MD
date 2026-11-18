# GitHub Copilot Customization Source

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](LICENSE)

GitHub Copilot / VS Code 用の prompts、agents、instructions、skills を管理する正本リポジトリです。

このリポジトリは日常作業用 workspace ではなく、VS Code User Data や Copilot CLI へ同期する customization assets の保管・整備を主目的にします。

## 構成

| パス                              | 目的                                                            |
| --------------------------------- | --------------------------------------------------------------- |
| `.github/agents/`                 | VS Code User Data に同期する custom agents                      |
| `.github/instructions/`           | VS Code / CLI に同期する自動適用 instructions                   |
| `.github/skills/`                 | Copilot Skills                                                  |
| `.github/.sync-ignore`            | 同期対象外ファイル名の一覧                                      |
| `.github/copilot-instructions.md` | この repo の作業ルール                                          |
| `AGENTS.md`                       | エージェント・プロンプト・instructions・skills の中央レジストリ |
| `docs/`                           | 補助ドキュメント                                                |
| `templates/`                      | companion project や補助テンプレート                            |
| `output_sessions/`                | セッションログ・作業記録の出力先（gitignore 対象）              |

旧 `prompts_sync/`, `agents_sync/`, `instructions_sync/` は廃止しました。現在は通常の `.github/agents/`, `.github/instructions/` を正本として扱います。`*.prompt.md` は Agent Host で読まれないため廃止し、再利用する workflow は skill にします。

## 同期先

| 種別         | Repo 側                                     | VS Code User Data                               | Copilot CLI                  |
| ------------ | ------------------------------------------- | ----------------------------------------------- | ---------------------------- |
| Agents       | `.github/agents/*.agent.md`                 | `%APPDATA%/Code/User/prompts/*.agent.md`        | 対象外                       |
| Instructions | `.github/instructions/**/*.instructions.md` | `%APPDATA%/Code/User/prompts/*.instructions.md` | `~/.copilot/instructions/**` (auto-loaded); manual references in `~/.copilot/references/**` (read on demand) |
| Skills       | `.github/skills/`                           | 対象外                                          | 必要に応じて別フロー         |

> Note: この repo を VS Code で開くと、`.github/instructions/` の assets が workspace customization として認識される可能性があります。この repo は主に保守・同期用として扱い、通常の開発作業 workspace とは分ける前提です。

## 使い方

### User Data / CLI へ同期する

`sync-to-global` agent を使います。

```
/agent sync-to-global
```

この agent は次を行います。

1. Repo 側正本と User Data / CLI の差分を検出
2. `.github/.sync-ignore` を尊重して除外
3. 新しい方、repo-only、global-only、CLI-only を表示
4. ユーザー確認後に同期
5. 結果と `git status --short` を報告

### User Data から repo へ反映する

逆方向（User Data → この repo）は `scripts/Sync-UserCustomizations.ps1` を使います。`-Source` 省略時は `~/.copilot/instructions`、`~/.copilot/references`、`~/.copilot/agents` をまとめて対象にし、参照メモは同名の既存 `.github/instructions/` mirror を、agent は `.github/agents/` を更新します。複数フォルダで同じファイル名があれば停止し、どのソースにも無い repo 側のファイルは削除候補として報告するだけで削除しません。引数なしは読み取りのみで、`-Apply` で変更分だけをミラーして commit / push します。`syncToGlobal: true` のファイルだけが対象で、監査ヒット時や既存の未コミット差分がある場合は書き込まず停止します。テストは `tests/scripts/` にあります。

### 個別 asset を確認する

詳細な一覧は [AGENTS.md](AGENTS.md) を参照してください。

## 主要 assets

### Agents

- [sync-to-global](.github/agents/sync-to-global.agent.md) — canonical `.github` assets と User Data / CLI を同期
- [enhanced-plan](.github/agents/enhanced-plan.agent.md) — 調査が必要な実装・移行・設計計画を source-aware に作成
- [workflow-designer](.github/agents/workflow-designer.agent.md) — エージェント/ワークフロー設計・レビュー
- [DeepResearch](.github/agents/DeepResearch.agent.md) — 深い調査・引用付きレポート生成
- [fact-checker](.github/agents/fact-checker.agent.md) — 事実・出典・リンク確認
- [ReportWriter](.github/agents/ReportWriter.agent.md) — 調査結果のレポート化

### Instructions

- [core](.github/instructions/core/)
- [dev](.github/instructions/dev/)
- [integrations](.github/instructions/integrations/)
- [git-publish-policy](.github/instructions/dev/git-publish-policy.instructions.md) - GitHub 公開同期と visibility 判断
- [copilot-loading](.github/instructions/core/copilot-loading.instructions.md) - Copilot CLI / VS Code Chat の読み込み場所と運用ルール
- [naming-conventions](.github/instructions/core/naming-conventions.instructions.md) - 命名規約（ファイル名、生成物、カスタマイズ資産）
- [prompts-metadata](.github/instructions/core/prompts-metadata.instructions.md) - prompt / instruction / agent の metadata 運用
- [terminal](.github/instructions/core/terminal.instructions.md) - PowerShell / Windows terminal 操作
- [user-data-default](.github/instructions/core/user-data-default.instructions.md) - User Data customization の既定スコープ
- [vscode-environment](.github/instructions/core/vscode-environment.instructions.md) - VS Code User Data / workspaceStorage 実用メモ
- [web-search](.github/instructions/integrations/web-search.instructions.md) - Brave / DuckDuckGo HTML / Copilot CLI web_search の使い分け

### Skills

- [agentic-workflow-guide](.github/skills/agentic-workflow-guide/SKILL.md)
- Waza 評価（`evaluate-waza-copilot-customizations` skill、private skills repo 管理）: [セットアップ](docs/waza-copilot-customizations-setup.md) / [companion template](templates/waza-copilot-customization-evals/README.md)

## 運用ルール

- 新しい agent / instruction は、まず `.github/agents/`, `.github/instructions/` のどちらが正しいかを判断する。再利用する workflow は `.github/skills/` に置く。
- `syncToGlobal: false` の資産は公開・同期対象外として扱う。
- 機密情報、顧客情報、個人アカウント実値、環境固有 ID の実値を入れない。
- User Data 側だけに残すもの、削除済みとして扱うものは `.github/.sync-ignore` にファイル名で記録する。
- 明示指示なしに `git push` しない。

## 関連ドキュメント

- [AGENTS.md](AGENTS.md)
- [.github/copilot-instructions.md](.github/copilot-instructions.md)
- [.github/agents/sync-to-global.agent.md](.github/agents/sync-to-global.agent.md)
