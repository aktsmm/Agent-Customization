# GitHub Copilot Agent Workflow Template

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](LICENSE)

GitHub Copilot × VS Code でエージェントワークフローを構築するためのテンプレートリポジトリです。  
エージェント定義・インストラクション・プロンプトのサンプルを収録しており、自分のプロジェクトにコピーしてすぐに使えます。

## 特徴

- 📦 **すぐ使えるサンプル** — エージェント、インストラクション、プロンプトの実用的なテンプレート
- 🎯 **ベストプラクティス準拠** — Anthropic / OpenAI / Microsoft のガイドラインを参考に設計
- 🔧 **カスタマイズ可能** — プロジェクトに合わせて自由に拡張・変更可能
- 📚 **Skill 同梱** — エージェント設計の参照ガイド（`agentic-workflow-guide`）を含む

## クイックスタート

```bash
# 1. テンプレートからリポジトリを作成（GitHub UI で「Use this template」）
# 2. または手動でクローン
git clone https://github.com/aktsmm/ghc_template.git

# 3. .github フォルダをプロジェクトにコピー
cp -r .github /path/to/your-project/
```

## 収録内容

| パス                              | 説明                                                                           |
| --------------------------------- | ------------------------------------------------------------------------------ |
| `.github/copilot-instructions.md` | 共有ガードレール（回答トーン、レビュー方針）                                   |
| `.github/agents/`                 | エージェント定義（`sample`, `orchestrator`, `sync-to-global`, `ghc-research`） |
| `.github/instructions/`           | ドメイン別ガイド（サブフォルダを作成して整理）                                 |
| `.github/prompts/`                | 再利用可能なプロンプト（`create-workflow`, `sample`）                          |
| `.github/skills/`                 | Copilot Skills（`agentic-workflow-guide`）                                     |
| `AGENTS.md`                       | 登録済みエージェント・関連アセットの一覧                                       |

## 使い方

### 1. エージェントを呼び出す

Copilot Chat で `/agent` コマンドを使用：

```
/agent sample          # サンプルエージェント
/agent orchestrator    # オーケストレーター
/agent ghc-research    # GitHub Copilot/VS Code 関連の調査
```

### 2. プロンプトを呼び出す

Copilot Chat で `/prompt` コマンドを使用：

```
/prompt create-workflow    # ワークフロー作成
/prompt sample             # プロンプト作成用テンプレート
```

### 3. 新しいエージェントを作成する

```bash
# サンプルをコピーして編集
cp .github/agents/sample.agent.md .github/agents/my-agent.agent.md

# AGENTS.md に追記
```

## ファイル構成

```
.github/
├── copilot-instructions.md    # Copilot 共通設定
├── agents/                    # エージェント定義
│   ├── sample.agent.md        # テンプレート
│   ├── orchestrator.agent.md  # オーケストレーター例
│   └── sync-to-global.agent.md
├── instructions/              # ドメイン別ルール
│   └── (サブフォルダを作成して整理)
├── prompts/                   # 再利用可能なプロンプト
│   ├── create-workflow.prompt.md
│   └── sample.prompt.md       # テンプレート
└── skills/                    # Copilot Skills
    └── agentic-workflow-guide/
```

### `instructions/` の推奨構成

プロジェクトに合わせてサブフォルダを作成してください：

```
instructions/
├── core/           # 共通ルール（セキュリティ、通信スタイル）
├── dev/            # 開発ルール（Git、Python、Node.js 等）
├── agents/         # エージェント設計ルール
└── integrations/   # 外部連携（Microsoft Docs MCP 等）
```

### グローバル設定との使い分け

VS Code では、ワークスペース用（`.github/`）とグローバル用（ユーザープロファイル）の 2 箇所にインストラクション/プロンプトを配置できます。

| 配置場所                 | パス                                            | 用途                       |
| ------------------------ | ----------------------------------------------- | -------------------------- |
| ワークスペース           | `.github/instructions/`, `.github/prompts/`     | プロジェクト固有のルール   |
| グローバル (Windows)     | `%APPDATA%/Code/User/instructions/`, `prompts/` | 全プロジェクト共通のルール |
| グローバル (macOS/Linux) | `~/.config/Code/User/instructions/`, `prompts/` | 全プロジェクト共通のルール |

**複数プロジェクトで共通して使いたいルール**（Git コミット規約、コーディングスタイル等）は、グローバル設定に配置することを推奨します。

> **Note**: このテンプレートリポジトリでは `_sync` サフィックスのフォルダ（`instructions_sync/`, `prompts_sync/`）を使用していますが、これは作者の環境でグローバル設定と同期するためのものです。テンプレートを使う際は、通常の `instructions/` や `prompts/` フォルダに配置してください。

## `copilot-instructions.md` と `AGENTS.md` の違い

| 観点 | `copilot-instructions.md` | `AGENTS.md`                   |
| ---- | ------------------------- | ----------------------------- |
| 対象 | GitHub Copilot 全般       | Coding Agent / Codex          |
| 用途 | 回答スタイル、ポリシー    | ビルド手順、タスク境界        |
| 例   | 「日本語で回答」          | 「`pnpm install` で依存解決」 |

## エージェント設計の原則

1. **目的を最初に固定する** — 何を作るか、品質基準、出力形式を明確に
2. **タスクを小さく分割する** — 1 つの巨大エージェントに全部やらせない
3. **単一責務（SRP）** — 調査・実装・レビューなど役割ごとに分離
4. **一方向の依存** — 循環構造（A → B → A）を作らない
5. **構造化データで受け渡し** — YAML / JSON / Markdown で情報を伝達
6. **プロンプトは短く** — 作業指示のみ、出力形式を明確に
7. **レビュー専用エージェントを用意** — 最終チェックは分離する

## オーケストレーター構成

複数エージェントを統括する場合の推奨構成：

```
.github/agents/
├── orchestrator.agent.md  # 司令塔（コード編集しない）
├── plan.agent.md          # 既存コード分析と実装方針
├── impl.agent.md          # TDD に沿った実装 & テスト
└── review.agent.md        # コードレビューと修正
```

**ポイント：**

- 各エージェントに「やること」と「やらないこと」を明記
- オーケストレーターは進行管理のみ、実作業はサブエージェントに委譲
- エージェント間は構造化データ（YAML/JSON）で受け渡し

## runSubagent 運用Tips

| 得意                         | 苦手                                     |
| ---------------------------- | ---------------------------------------- |
| 長尺調査、ログ解析           | 結果の深掘り（追加質問不可）             |
| ファイル単位の独立作業       | 軽量タスク（オーバーヘッドが大きい）     |
| 計画→実装→レビューの段階分離 | 前ステップの詳細を保持したいワークフロー |

**注意点：**

- サブエージェントはステートレス（追加質問できない）
- 直列実行のみ（並列化は非対応）
- リトライ上限を設定して暴走を防ぐ

## ベストプラクティス

### Do ✅

- 1 エージェント = 1 つの役割（単一責務）
- エージェント間は YAML/JSON で受け渡し
- 同じ入力なら同じ結果（冪等性）
- 最終チェックは専用エージェントで
- リトライ上限とフォールバックを明記

### Don't ❌

- 1 つのエージェントに全部やらせる
- 循環依存（A → B → A）を作る
- 長文プロンプトを書く
- `/dev/null` へのリダイレクト
- `git push` を自動実行

## 参考資料

<details>
<summary>📚 公式ドキュメント</summary>

**GitHub Copilot / VS Code**

- [Chat in IDE](https://docs.github.com/en/copilot/how-tos/chat-with-copilot/chat-in-ide) — Chat modes, subagents, plan mode
- [Custom Agents in VS Code](https://code.visualstudio.com/docs/copilot/customization/custom-agents) — エージェント設定
- [Custom Agents Configuration](https://docs.github.com/en/copilot/reference/custom-agents-configuration) — YAML リファレンス
- [Copilot Best Practices](https://docs.github.com/en/copilot/using-github-copilot/best-practices-for-using-github-copilot)
- [awesome-copilot](https://github.com/github/awesome-copilot) — エージェント例・ツール集

</details>

<details>
<summary>📖 プロンプトエンジニアリング</summary>

**Anthropic**

- [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents) — エージェント設計の原則
- [Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) — コンテキスト設計
- [Writing Tools for Agents](https://www.anthropic.com/engineering/writing-tools-for-agents) — ツール設計
- [Prompt Engineering Tutorial](https://github.com/anthropics/prompt-eng-interactive-tutorial)
- [Anthropic Cookbook](https://github.com/anthropics/anthropic-cookbook)

**その他**

- [OpenAI Prompt Engineering](https://platform.openai.com/docs/guides/prompt-engineering)
- [Azure OpenAI Prompt Engineering](https://learn.microsoft.com/azure/ai-services/openai/concepts/prompt-engineering)
- [Prompting Guide](https://www.promptingguide.ai/) — 体系的なチートシート

</details>

<details>
<summary>🙏 Inspiration & Thanks</summary>

- [openjny/dotgh](https://github.com/openjny/dotgh) — 高機能なテンプレート管理ツール
- [dotgh 解説記事](https://zenn.dev/openjny/articles/4313236f8886e4)
- [runSubagent 解説](https://zenn.dev/openjny/articles/2619050ec7f167)
- [オーケストレーター構成](https://zenn.dev/openjny/articles/e11450f61d067f)

</details>

## ライセンス

[CC BY-NC-SA 4.0](LICENSE)

このリポジトリは Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International ライセンスの下で公開されています。

- ✅ 帰属表示を行えば自由に共有・改変可能
- ❌ 商用利用は禁止（商用利用を希望する場合はお問い合わせください）
- ❌ AI/ML トレーニングへの使用は禁止

## コントリビュート

Issue や Pull Request は歓迎です。バグ報告、機能提案、ドキュメント改善など、お気軽にどうぞ。
