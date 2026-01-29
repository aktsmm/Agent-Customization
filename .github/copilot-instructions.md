# Repository Copilot Instructions

このリポジトリは **GitHub Copilot カスタマイズテンプレート集**です。
エージェント、プロンプト、インストラクション、Skills の設計パターンとベストプラクティスを提供します。

## Project Structure

| ディレクトリ            | 説明                                               |
| ----------------------- | -------------------------------------------------- |
| `.github/agents/`       | カスタムエージェント定義（`.agent.md`）            |
| `.github/prompts/`      | 再利用可能なプロンプト（`.prompt.md`）             |
| `.github/instructions/` | ドメイン別インストラクション（`.instructions.md`） |
| `.github/skills/`       | Agent Skills（特殊スキル定義）                     |
| `output_sessions/`      | セッションログ・作業記録の出力先                   |
| `docs/`                 | プロジェクトドキュメント                           |

## Key Files

- `AGENTS.md` - エージェント一覧・関連アセットのマップ（SSOT）
- `.github/copilot-instructions.md` - グローバルガイドライン（このファイル）
- `README.md` - プロジェクト概要・クイックスタート

---

## エージェント行動指針 (Agent Behavior)

1.  **計画重視 (Plan First)**:
    - 複雑なタスク（機能追加、リファクタリング、デバッグ）に着手する前に、必ずステップバイステップの計画を提示してください。
    - ユーザーの承認を得てから実行に移ることを基本とします（明示的な許可がある場合を除く）。

2.  **コンテキスト認識 (Context Awareness)**:
    - 作業前に必ず関連ファイル（`README.md`, `package.json`, 関連ソースコード）を読み込み、プロジェクトの文脈を理解してください。
    - 推測でコードを書かず、`grep_search` や `file_search` を活用して既存の実装パターンを確認してください。

3.  **自律的な検証 (Self-Correction)**:
    - コードを変更した後は、可能な限り検証（ビルド、テスト実行、リンターチェック）を行ってください。
    - エラーが発生した場合は、エラーメッセージを分析し、修正案を提示・実行してください。
    - 同一エラーに対する修正は最大3回まで試行し、解決しない場合はユーザーに状況を報告してください。

4.  **コンテキスト最小化 (Context Minimalism)**:
    - 目的達成に必要な最小限の情報だけを読み込み、不要な長文の貼り付けや広範な検索を避けてください。
    - 参照は高信号のファイル/セクションに限定し、根拠を明示してください。

5.  **フェイルファースト (Fail Fast)**:
    - 作業開始前に「Phase 0: 事前チェック」を実施してください。
    - 主要ファイル/設定の存在確認（例: `AGENTS.md`, `.github/instructions/**`, 対象ファイルパスの検証）。
    - `manage_todo_list` にゲート条件を設定し、未充足なら中断・是正してから再開。

6.  **進捗の可視化 (Transparency)**:
    - 複数ステップのタスクでは `manage_todo_list` を活用し、進捗を明示してください。
    - 各フェーズの開始・完了時に簡潔なステータスを報告してください。
    - 長時間かかる処理の前には、予想される所要時間や影響範囲を伝えてください。

---

## コーディング規約

### 基本原則

- **DRY (Don't Repeat Yourself)**: 重複を避け、再利用可能なコードを生成
- **SOLID**: 単一責任の原則に従った設計
- **SSOT (Single Source of Truth)**: 情報は一箇所で管理し、他はそこを参照

### 命名規約

- **ファイル名**: `kebab-case` を使用（例: `my-agent.agent.md`）
- **エージェント名**: Title Case（例: `Test Specialist`）
- **変数/関数**: 言語の標準規約に従う

### ドキュメント

- 回答には必ず**参照元 URL** と**根拠**を明記
- コード変更時は変更理由を簡潔にコメント

---

## ツール使用ガイドライン

### MCP ツール活用

利用可能な MCP ツールを積極的に活用し、最新の公式情報に基づいた回答を行ってください：

- **Microsoft Docs MCP**: Azure/Microsoft 公式ドキュメント検索
- **GitHub MCP**: リポジトリ情報・Issue・PR 操作
- **Bicep MCP**: Azure リソース定義のベストプラクティス

### ターミナル操作

- PowerShell 互換コマンドを優先
- 破壊的操作（削除、上書き）の前に確認を求める
- 長時間コマンドは `isBackground: true` で実行

---

## エージェント設計

プロンプト / エージェント / インストラクションを作成・編集する際は、以下の Skills を参照してください。

| Skill                                                            | 用途                             | トリガー                        |
| ---------------------------------------------------------------- | -------------------------------- | ------------------------------- |
| [agentic-workflow-guide](skills/agentic-workflow-guide/SKILL.md) | ワークフロー設計・レビュー・改善 | `.github/` 配下のファイル編集時 |

---

## ファイルマップ

エージェント一覧・関連アセットの詳細は [AGENTS.md](../AGENTS.md) を参照してください。

<!-- skill-ninja-START -->
## Installed Skills

The following skills are available in this workspace.

| Skill | When to Use |
|-------|-------------|
| [agentic-workflow-guide](skills/agentic-workflow-guide/SKILL.md) | Create: New .agent.md, workflow architecture, scaffolding; Review: Orchestrator not delegating, design principle check, context overflow |

<!-- skill-ninja-END -->
