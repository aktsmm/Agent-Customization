---
description: "Copilot CLI と VS Code GitHub Copilot Chat の instructions / prompts / skills / toolsets 読み込み場所と設定の運用ルール"
applyTo: "**/*.prompt.md,**/*.instructions.md,**/*.agent.md,**/*.toolsets.jsonc,**/SKILL.md,**/copilot-instructions.md,**/AGENTS.md"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-07-13 -->

# Copilot CLI / VS Code インストラクション読み込みルール

エージェントやインストラクションが「どこから読まれるか」と「どこに置くべきか」を判断するための整理。

> 補足: `.github/copilot-instructions.md` と `AGENTS.md` は読み込み対象だが、User Data 側の metadata/frontmatter ルールをそのまま要求する対象ではない。

## VS Code GitHub Copilot Chat で自動ロードされる主な file

| ファイル | スコープ | 備考 |
| --- | --- | --- |
| `$HOME/.copilot/instructions/**/*.instructions.md` | ユーザー | 公式 Docs 記載のユーザープロファイル instructions |
| `%APPDATA%/Code/User/prompts/*.instructions.md` | ユーザー | VS Code プロファイル固有の User Data instructions |
| `.github/copilot-instructions.md` | ワークスペース | repo-wide の短い原則 |
| `.github/instructions/**/*.instructions.md` | ワークスペース | `applyTo` 付きの scoped rule |
| `AGENTS.md` | ワークスペース | agent / workflow の入口 |
| `CLAUDE.md` 系 | 互換 | Claude Code 互換の instructions |

## VS Code で確認する場所

- 読み込み経路は Chat Diagnostics か `Chat: Configure Instructions` の tooltip で確認する
- `chat.instructionsFilesLocations` が `false` の場所は、Docs に載っていても自動ロードされない

## instructions 添付を制御する設定

| 設定 | 既定 | 役割 |
| --- | --- | --- |
| `chat.includeApplyingInstructions` | true | `applyTo` 一致の instruction を system prompt に添付する |
| `chat.includeReferencedInstructions` | true | instruction / agent 中の Markdown link 参照先を**再帰添付**する |

- `chat.includeReferencedInstructions: true` は、エージェント起動時にリンク到達閉包（agent / instruction / skill 本文）を丸ごと system prompt へ展開する。catalog（`AGENTS.md` → `README.md` など）への hub リンクが多いと、起動時だけ system prompt が桁違いに膨張し、実タスク指示が希釈されて汎用応答に退行する
- 症状: 通常チャットは正常なのに `@agent` 起動時だけ指示を無視して「何を進めますか」型に落ちる。Markdown link を辿る挙動なので skills や個別ファイルの量を削っても直らない
- 切り分け: `debug-logs/<session>/system_prompt_0.json` のサイズと `<attachment filePath` 数を、通常チャットとエージェント起動で比較する。エージェント側だけ数倍なら再帰添付が原因
- 対処: `chat.includeReferencedInstructions: false`。ファイルを書き換えず Markdown link を残したまま起動時の自動先読みだけ止める。必要なファイルはエージェントが都度 `read_file` で読める。前提として必須ルールは `applyTo` で scoped した instruction 本体に残し、リンク先は補助的深掘りに限定する

## Instruction Priority

- VS Code Chat で異なる instruction scope が競合する場合は、Personal > Repository > Organization の順で優先する。
- 複数の instruction file が同時に適用される場合、個別ファイル間の適用順序は保証されない。競合する命令を順序依存で解決しない。

## Copilot CLI で自動ロードされる主な file

| ファイル | スコープ | 備考 |
| --- | --- | --- |
| `$HOME/.copilot/copilot-instructions.md` | グローバル | CLI 全体の原則 |
| `.github/copilot-instructions.md` | ワークスペース | repo-wide の原則 |
| `.github/instructions/**/*.instructions.md` | ワークスペース | `applyTo` 付き rule |
| `AGENTS.md` | ワークスペース | agent / workflow の入口 |
| `CLAUDE.md` / `GEMINI.md` | 互換 | 互換 file |

- 追加ディレクトリを CLI に読ませるときは `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` を使う

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

## 配置の判断基準

| 内容 | 配置先 |
| --- | --- |
| VS Code Chat の個人 rule | VS Code User Data または `$HOME/.copilot/instructions/` |
| Copilot CLI の個人 rule | `$HOME/.copilot/copilot-instructions.md` |
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
