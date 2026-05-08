---
description: "Copilot CLI と VS Code GitHub Copilot Chat の instructions / prompts / skills 読み込み場所と設定の運用ルール"
applyTo: "**/*.prompt.md,**/*.instructions.md,**/*.agent.md,**/SKILL.md,**/copilot-instructions.md,**/AGENTS.md"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Copilot CLI / VS Code インストラクション読み込みルール

エージェントやインストラクションがいつ・どこから読まれるかの整理。
ファイルを追加・編集するときにどこに置くべきか判断するために参照する。

## VS Code GitHub Copilot Chat で自動ロードされるファイル

> 補足: `.github/copilot-instructions.md` と `AGENTS.md` は読み込み対象だが、User Data 側の metadata/frontmatter ルールをそのまま要求する対象ではない。

| ファイル | スコープ | 備考 |
|---------|---------|------|
| `$HOME/.copilot/instructions/**/*.instructions.md` | ユーザー（VS Code） | 公式 Docs 記載のユーザープロファイル instructions |
| `%APPDATA%/Code/User/prompts/*.instructions.md` | ユーザー（VS Code） | VS Code プロファイル固有の User Data 側 instructions |
| `.github/copilot-instructions.md` | ワークスペース | プロジェクト固有のルール |
| `.github/instructions/**/*.instructions.md` | ワークスペース（`applyTo` パターン） | プロジェクト分野別ルール |
| `AGENTS.md` | ワークスペース（git root & cwd） | スキルインデックス等 |
| `CLAUDE.md` / `.claude/CLAUDE.md` / `$HOME/.claude/CLAUDE.md` | 互換 | Claude Code 互換の always-on instructions |

> 注意: 公式 Docs 上は VS Code のユーザープロファイル instructions として `$HOME/.copilot/instructions` が記載されている。実際に読み込まれたかは Chat の Diagnostics または `Chat: Configure Instructions` の tooltip で確認する。

### VS Code の読み込み場所設定

VS Code Chat の instructions 読み込み場所は `chat.instructionsFilesLocations` で制御できる。
公式 Docs に載っている場所でも、この設定で `false` になっている場合は読み込まれない。

```json
"chat.instructionsFilesLocations": {
	".github/instructions": true,
	"~/.copilot/instructions": false,
	"~/.claude/rules": false
}
```

読み込み漏れや重複が疑わしい場合は、まずこの設定と Chat Diagnostics を確認する。

## Copilot CLI で自動ロードされるファイル

| ファイル | スコープ | 備考 |
|---------|---------|------|
| `$HOME/.copilot/copilot-instructions.md` | グローバル（全セッション） | ユーザー共通の原則 |
| `.github/copilot-instructions.md` | ワークスペース | プロジェクト固有のルール |
| `.github/instructions/**/*.instructions.md` | ワークスペース（`applyTo` パターン） | プロジェクト分野別ルール |
| `AGENTS.md` | ワークスペース（git root & cwd） | スキルインデックス等 |
| `CLAUDE.md` / `GEMINI.md` | ワークスペース | 互換ファイル |

> 注意: Copilot CLI で追加ディレクトリを読ませる場合は、`COPILOT_CUSTOM_INSTRUCTIONS_DIRS` に対象ディレクトリを指定する。CLI は指定ディレクトリ内の `AGENTS.md` と `.github/instructions/**/*.instructions.md` を探す。

## 明示的に呼んだときだけ読まれるファイル

| ファイル | 呼び出し方 | 備考 |
|---------|-----------|------|
| `.github/agents/*.agent.md` | VS Code: `@agent名`、CLI: task ツールの custom agent | エージェント定義 |
| `$HOME/.copilot/skills/*/SKILL.md` | `skill` ツールで invoke | ユーザーレベルスキル |
| `.github/skills/*/SKILL.md` | `skill` ツールで invoke | プロジェクトスキル |

## 配置の判断基準

| 学びの性質 | 配置先 | 例 |
|-----------|--------|-----|
| VS Code Chat の個人ルール | VS Code User Data または `$HOME/.copilot/instructions/{category}/` | Git、Python、ターミナル操作 |
| Copilot CLI の個人ルール | `$HOME/.copilot/copilot-instructions.md` | CLI 全体に効かせる共通原則 |
| 特定ワークスペース固有 | `.github/copilot-instructions.md` | D365カテゴリマッピング |
| 特定タスクの手順 | `.github/agents/` or `.github/skills/` | OCR仕分け、経費精算自動化 |
| 長い外部ツール連携ワークフロー | `$HOME/.copilot/skills/` or `.github/skills/` | Browser/CDP automation、PowerPoint automation |
| 短い外部サービス参照ルール | `$HOME/.copilot/instructions/integrations/` または VS Code User Data | MS Learn MCP、ローカルネットワーク調査 |

## 公式 Docs

- VS Code custom instructions: https://code.visualstudio.com/docs/copilot/customization/custom-instructions
- VS Code prompt files: https://code.visualstudio.com/docs/copilot/customization/prompt-files
- VS Code Agent Skills: https://code.visualstudio.com/docs/copilot/customization/agent-skills
- GitHub Copilot CLI custom instructions: https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions
- GitHub repository custom instructions: https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot
