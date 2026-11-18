---
description: "Agent Host（Copilot CLI harness）と Copilot CLI が instructions / skills / agents / MCP を読み込む場所と、個人・ワークスペース資産の置き場所の判断基準"
applyTo: "**/*.instructions.md,**/*.agent.md,**/*.toolsets.jsonc,**/SKILL.md,**/copilot-instructions.md,**/AGENTS.md,**/mcp-config.json"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-11-19 -->

# Copilot 読み込みルール

資産が「どこから読まれるか」と「どこに置くか」を判断するための整理。VS Code の Agent Host と Copilot CLI は同じ Copilot 用フォルダを読む。

## 自動で読まれる file

| ファイル | スコープ | 備考 |
| --- | --- | --- |
| `$HOME/.copilot/copilot-instructions.md` | 個人 | 常時ロード。短く保つ |
| `$HOME/.copilot/instructions/**/*.instructions.md` | 個人 | 再帰的にロードされる。`applyTo` が無い file は常時ロードされ、`description` は読み込みの選別に使われない（選別されるのは skill の description）。使う場面が読めない環境事実や復旧メモは常時ロードでよい。場面で絞りたい手順は skill にする |
| `.github/copilot-instructions.md` | ワークスペース | repo-wide の短い原則 |
| `.github/instructions/**/*.instructions.md` | ワークスペース | `applyTo` 付きの scoped rule |
| `AGENTS.md` | ワークスペース | agent / workflow の入口 |
| `CLAUDE.md` / `GEMINI.md` | 互換 | 互換 file |

- `*.prompt.md` は Agent Host では読まれない。再利用する workflow は skill にする
- VS Code の `chat.instructionsFilesLocations` / `chat.agentSkillsLocations` は旧 Local harness 用で、Agent Host の読み込みには効かない
- 追加ディレクトリを CLI に読ませるときは `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` を使う

## 明示的に呼んだときだけ読まれる file

| ファイル | 呼び出し方 | 備考 |
| --- | --- | --- |
| `$HOME/.copilot/skills/*/SKILL.md` | `skill` ツール、`/名前` | 個人 skill |
| `.github/skills/*/SKILL.md` | 同上 | ワークスペース skill |
| `$HOME/.copilot/agents/*.agent.md`、`.github/agents/*.agent.md` | agent 名の指定 | エージェント定義 |
| `$HOME/.copilot/references/**` | 用途に合う入口からファイルパスを指定 | 自動ロードされない個人用参照メモ |

- 都度呼び出し専用にする skill は frontmatter に `disable-model-invocation: true` を付ける。`/名前` でのみ実行され、モデルは関連性で自動読み込みしない

## MCP

- 個人の MCP は `$HOME/.copilot/mcp-config.json`（`mcpServers`）に置く。VS Code 側の `mcp.json` と二重定義しない
- 秘密値は `env` に直書きせず `"${ENV_NAME}"` で User 環境変数を参照する。環境変数を追加・変更したあとは VS Code を完全に再起動する
- remote の OAuth は、既定の VS Code client が事前承認されていないサーバー（例: Work IQ の `AADSTS65002`）では、flat なキー（`oauthClientId`、`oauthPublicClient`、`auth.redirectPort`）で client を固定する。VS Code 形式の `oauth: {clientId}` は migration で自動変換されない
- MCP 設定を変えても既存セッションの tool catalog は直ちに更新されない。再読み込みか新しいセッションで、必要な tool が公開されたことを確認する
- HTTP MCP を直接診断するときは `initialize` → `notifications/initialized` → `tools/list` / `tools/call` の順にし、認証情報と session ID の値を出力・保存しない
- リモート GitHub MCP の追加 toolset は HTTP header `X-MCP-Toolsets: default,<toolset>` で有効化する。`github_support_docs_search` は remote-only で `default` には含まれない

## Agent の tools

- `.agent.md` の `tools:` に書く VS Code のツール ID（`read/readFile`、`execute/runInTerminal` など）や MCP 名（`workiq/*` など）は Agent Host で通る保証がない。変更したら `/agent` で実効ツールを確認する
- MCP の指定は実際のサーバー名（`workiqLocal`、`workiqCloud` など）に合わせる
- `*.toolsets.jsonc` の `"tools"` は toolset 側の短い ID（例: `execute`, `read`）を使い、agent frontmatter の一覧をそのまま移植しない

## 配置の判断基準

| 内容 | 配置先 |
| --- | --- |
| すべての会話に効く個人の短い原則 | `$HOME/.copilot/copilot-instructions.md` |
| 個人の詳細ルール | `$HOME/.copilot/instructions/**` |
| 個人の手動参照メモ | `$HOME/.copilot/references/**` |
| 個人の再利用 workflow | `$HOME/.copilot/skills/` |
| repo-wide の短い rule | `.github/copilot-instructions.md` |
| 特定ファイル群に効く rule | `.github/instructions/**/*.instructions.md` |
| 特定の workflow / task | `.github/agents/` または `.github/skills/` |

- 正本は skill が private skills repo、instructions が公開 repo の `.github/instructions/`。`$HOME/.copilot` は作業コピーなので、直接編集してよく、編集後に正本へ反映する

## References

Verified: 2026-10-18。URL は仕様更新の確認用で、実行に必要なルールは本文を正本とする。

- VS Code: Migrate customizations to the Copilot harness: https://code.visualstudio.com/docs/agent-customization/migrate-customizations
- VS Code Agent Skills: https://code.visualstudio.com/docs/agent-customization/agent-skills
- GitHub Copilot CLI custom instructions: https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions
- GitHub Copilot CLI MCP servers: https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-mcp-servers
- GitHub MCP toolsets: https://docs.github.com/en/enterprise-cloud@latest/copilot/how-tos/provide-context/use-mcp-in-your-ide/configure-toolsets
