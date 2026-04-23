---
applyTo: "**"
---

# Copilot CLI / VS Code インストラクション読み込みルール

エージェントやインストラクションがいつ・どこから読まれるかの整理。
ファイルを追加・編集するときにどこに置くべきか判断するために参照する。

## Copilot CLI で自動ロードされるファイル

| ファイル | スコープ | 備考 |
|---------|---------|------|
| `$HOME/.copilot/copilot-instructions.md` | グローバル（全セッション） | ユーザー共通の原則 |
| `$HOME/.copilot/instructions/**/*.instructions.md` | グローバル（`applyTo` パターンで絞込） | 分野別ルール |
| `.github/copilot-instructions.md` | ワークスペース | プロジェクト固有のルール |
| `.github/instructions/**/*.instructions.md` | ワークスペース（`applyTo` パターン） | プロジェクト分野別ルール |
| `AGENTS.md` | ワークスペース（git root & cwd） | スキルインデックス等 |
| `CLAUDE.md` / `GEMINI.md` | ワークスペース | 互換ファイル |

## 明示的に呼んだときだけ読まれるファイル

| ファイル | 呼び出し方 | 備考 |
|---------|-----------|------|
| `.github/agents/*.agent.md` | VS Code: `@agent名`、CLI: task ツールの custom agent | エージェント定義 |
| `$HOME/.copilot/skills/*/SKILL.md` | `skill` ツールで invoke | ユーザーレベルスキル |
| `.github/skills/*/SKILL.md` | `skill` ツールで invoke | プロジェクトスキル |

## 配置の判断基準

| 学びの性質 | 配置先 | 例 |
|-----------|--------|-----|
| 全プロジェクト共通の原則 | `$HOME/.copilot/instructions/{category}/` | COM操作、Git、Python |
| 特定ワークスペース固有 | `.github/copilot-instructions.md` | D365カテゴリマッピング |
| 特定タスクの手順 | `.github/agents/` or `.github/skills/` | OCR仕分け、経費精算自動化 |
| 外部ツール連携の詳細 | `$HOME/.copilot/instructions/integrations/` | Edge CDP、MS Learn MCP |
