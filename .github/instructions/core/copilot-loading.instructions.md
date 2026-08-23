---
description: "Copilot CLI と VS Code GitHub Copilot Chat の instructions / prompts / skills / toolsets 読み込み場所と設定の運用ルール"
applyTo: "**/*.prompt.md,**/*.instructions.md,**/*.agent.md,**/*.toolsets.jsonc,**/SKILL.md,**/copilot-instructions.md,**/AGENTS.md"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-08-24 -->

# Copilot CLI / VS Code インストラクション読み込みルール

エージェントやインストラクションが「どこから読まれるか」と「どこに置くべきか」を判断するための整理。

> 補足: `.github/copilot-instructions.md` と `AGENTS.md` は読み込み対象だが、User Data 側の metadata/frontmatter ルールをそのまま要求する対象ではない。

## 配置の三層ルール

| 置き場 | VS Code Chat | Copilot CLI | 用途 |
| --- | --- | --- | --- |
| `$HOME/.copilot/copilot-instructions.md` | 読む（常時） | 読む（常時） | **共通**。always-on なので短く保つ |
| `$HOME/.copilot/instructions/**` | 読まない | 読む（再帰） | **CLI 固有** |
| `%APPDATA%/Code/User/prompts/**` | 読む | 読まない | **VS Code 固有** |

- 両方で必要な詳細ルールは自動同期されない。片方を編集したら同じターンでもう片方も更新する

## VS Code GitHub Copilot Chat で自動ロードされる主な file

| ファイル | スコープ | 備考 |
| --- | --- | --- |
| `$HOME/.copilot/copilot-instructions.md` | ユーザー | **常時ロードされる**。`github.copilot.chat.codeGeneration.useInstructionFiles`（既定 true）が gate で、`.github/copilot-instructions.md` と**同じスイッチ**。片方だけ切ることはできない（1.134.0 の実装で確認） |
| `$HOME/.copilot/instructions/**/*.instructions.md` | ユーザー | `chat.instructionsFilesLocations` 次第。この環境では `false` にして CLI 専用ゾーンにしている |
| `%APPDATA%/Code/User/prompts/*.instructions.md` | ユーザー | VS Code プロファイル固有の User Data instructions |
| `.github/copilot-instructions.md` | ワークスペース | repo-wide の短い原則 |
| `.github/instructions/**/*.instructions.md` | ワークスペース | `applyTo` 付きの scoped rule |
| `AGENTS.md` | ワークスペース | agent / workflow の入口。`chat.useAgentsMdFile` が gate |
| `CLAUDE.md` 系 | 互換 | workspace root / `.claude/` / **ユーザーホーム `~/.claude/CLAUDE.md`** を探索。`chat.useClaudeMdFile` が gate |

## VS Code で確認する場所

- 読み込み経路は Chat Diagnostics か `Chat: Configure Instructions` の tooltip で確認する
- `chat.instructionsFilesLocations` が `false` の場所は、Docs に載っていても自動ロードされない

## instructions 添付を制御する設定

| 設定 | 既定 | 役割 |
| --- | --- | --- |
| `chat.includeApplyingInstructions` | true | `applyTo` 一致の instruction を system prompt に添付する |
| `chat.includeReferencedInstructions` | false（1.131.0 で確認） | instruction / agent 中の Markdown link 参照先を**再帰添付**する |

- `chat.includeReferencedInstructions` を有効にすると、エージェント起動時にリンク到達閉包（agent / instruction / skill 本文）を丸ごと system prompt へ展開する。catalog（`AGENTS.md` → `README.md` など）への hub リンクが多いと、起動時だけ system prompt が桁違いに膨張し、実タスク指示が希釈されて汎用応答に退行する
- 1.131.0 時点で既定は `false`、かつこの設定を参照するのは Local agent harness だけ。無効でも Edit モードでは参照 instructions が添付される
- 症状: 通常チャットは正常なのに `@agent` 起動時だけ指示を無視して「何を進めますか」型に落ちる。Markdown link を辿る挙動なので skills や個別ファイルの量を削っても直らない
- 切り分け: `debug-logs/<session>/system_prompt_0.json` のサイズと `<attachment filePath` 数を、通常チャットとエージェント起動で比較する。エージェント側だけ数倍なら再帰添付が原因
- 対処: 既定が `false` の版では追加設定は不要。明示的に `true` にしている場合や既定が `true` だった旧版では `false` にする。ファイルを書き換えず Markdown link を残したまま起動時の自動先読みだけ止める。必要なファイルはエージェントが都度 `read_file` で読める。前提として必須ルールは `applyTo` で scoped した instruction 本体に残し、リンク先は補助的深掘りに限定する

## Instruction Priority

- VS Code Chat で異なる instruction scope が競合する場合は、Personal > Repository > Organization の順で優先する。
- 複数の instruction file が同時に適用される場合、個別ファイル間の適用順序は保証されない。競合する命令を順序依存で解決しない。

## Copilot CLI で自動ロードされる主な file

| ファイル | スコープ | 備考 |
| --- | --- | --- |
| `$HOME/.copilot/copilot-instructions.md` | グローバル | CLI 全体の原則。VS Code Chat も読む共通ファイル |
| `$HOME/.copilot/instructions/**/*.instructions.md` | グローバル | **再帰的に自動ロードされる**（2026-08-24 にカナリアで実測。ルート直下・サブフォルダとも有効）。`COPILOT_CUSTOM_INSTRUCTIONS_DIRS` は不要 |
| `.github/copilot-instructions.md` | ワークスペース | repo-wide の原則 |
| `.github/instructions/**/*.instructions.md` | ワークスペース | `applyTo` 付き rule |
| `AGENTS.md` | ワークスペース | agent / workflow の入口 |
| `CLAUDE.md` / `GEMINI.md` | 互換 | 互換 file |

- 追加ディレクトリを CLI に読ませるときは `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` を使う
- 読み込みを実測するときは、一意トークンを返させる使い捨ての canary instruction を置き、`copilot -p "<token>" --silent` で確認して削除する

## 明示的に呼んだときだけ読まれる file

| ファイル | 呼び出し方 | 備考 |
| --- | --- | --- |
| `.github/agents/*.agent.md` | `@agent名` など | エージェント定義 |
| `$HOME/.copilot/skills/*/SKILL.md` | `skill` ツール | ユーザースキル |
| `.github/skills/*/SKILL.md` | `skill` ツール | プロジェクトスキル |

## Toolsets と Agent Tools

- `.agent.md` の YAML `tools:` は `vscode/installExtension` のような namespace/toolName 形式を使う
- `*.toolsets.jsonc` の `"tools"` は toolset 側の短い ID / category 名（例: `execute`, `read`, `microsoft_docs_search`）を使う
- agent frontmatter の tools 一覧を `*.toolsets.jsonc` にそのまま移植しない。schema warning が `problems` に出ないこともあるため、既存例とエディタ上の警告も確認する
- リモート GitHub MCP の追加 toolset は HTTP header `X-MCP-Toolsets: default,<toolset>` で有効化する。`github_support_docs_search` は remote-only で、`default` には含まれない。
- `mcp.json` の変更後も既存 chat の tool catalog は直ちに更新されない。MCP server を再接続するか新しい chat を開き、必要な tool が公開されたことを確認する。
- HTTP MCP を直接診断するときは `initialize` → `notifications/initialized` → `tools/list` / `tools/call` の順にし、認証情報と session ID の値を出力・保存しない。

## 配置の判断基準

| 内容 | 配置先 |
| --- | --- |
| VS Code Chat と CLI で共通の個人 rule | `$HOME/.copilot/copilot-instructions.md`（always-on なので短く） |
| VS Code Chat 固有の個人 rule | VS Code User Data `%APPDATA%/Code/User/prompts/` |
| Copilot CLI 固有の個人 rule | `$HOME/.copilot/instructions/**` |
| repo-wide の短い rule | `.github/copilot-instructions.md` |
| 特定ファイル群に効く rule | `.github/instructions/**/*.instructions.md` |
| 特定 workflow / task | `.github/agents/` または `.github/skills/` |

## References

Verified: 2026-07-13。URL は人間による仕様更新の確認用であり、実行に必要なルールは本文を正本とする。

- VS Code custom instructions: https://code.visualstudio.com/docs/copilot/customization/custom-instructions
- VS Code prompt files: https://code.visualstudio.com/docs/copilot/customization/prompt-files
- VS Code Agent Skills: https://code.visualstudio.com/docs/copilot/customization/agent-skills
- GitHub Copilot CLI custom instructions: https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions
- GitHub repository custom instructions: https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot
- GitHub custom instruction support matrix: https://docs.github.com/en/copilot/reference/custom-instructions-support
- GitHub Copilot Code Review guidance: https://docs.github.com/en/copilot/tutorials/customize-code-review
- GitHub MCP toolsets: https://docs.github.com/en/enterprise-cloud@latest/copilot/how-tos/provide-context/use-mcp-in-your-ide/configure-toolsets
