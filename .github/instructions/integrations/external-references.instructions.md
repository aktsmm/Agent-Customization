# External References (Prompts / Reviews) — Summary Instructions

このファイルは、README の External References を実務に落とし込むための要点まとめ。各 URL は必ず参照元として残し、詳細は原文を確認する。

---

## OpenAI — Prompt Engineering

- URL: https://platform.openai.com/docs/guides/prompt-engineering
- 要点:
  - モデル選択は性能/コスト/速度のトレードオフを意識して選ぶ。
  - `instructions`/メッセージロールで指示の優先度を分ける。
  - 明確な指示・例示（few-shot）・構造化（Markdown/XML）で意図を伝える。
  - コンテキストは必要十分にし、タスクは分割して指示する。
  - 出力形式の指定・プライミング（cue）で結果の形を制御する。
  - プロンプトは evals で評価し、モデル更新時の劣化を監視する。

## Anthropic — Building Effective Agents

- URL: https://www.anthropic.com/engineering/building-effective-agents
- 要点:
  - まず最小構成で始め、必要に応じて複雑化する。
  - 「ワークフロー（固定経路）」と「エージェント（動的判断）」を区別する。
  - 代表的パターン: prompt chaining / routing / parallelization / orchestrator-workers / evaluator-optimizer。
  - エージェントはツール結果で進捗確認し、明確な停止条件を設ける。
  - フレームワークは便利だが抽象化の弊害に注意し、内部を理解する。

## Anthropic — Effective Context Engineering

- URL: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- 要点:
  - コンテキストは有限資源。高シグナル最小集合を目指す。
  - システム指示は具体すぎず曖昧すぎない「適正な粒度」を保つ。
  - ツールは役割を明確化し、冗長・重複を避ける。
  - 例示は「代表例」を少数に絞り、網羅の詰め込みは避ける。
  - 長期タスクでは compaction / ノート取り / サブエージェントで記憶管理。
  - 事前取得とジャストインタイム取得のハイブリッドを検討する。

## Claude Code — Best Practices

- URL: https://code.claude.com/docs/en/best-practices
- 要点:
  - 検証基準（テスト/期待出力/スクショ）を明示して自己検証させる。
  - 探索→計画→実装→コミットの分離が効果的。
  - 具体的な文脈・参照ファイル・制約条件を明示する。
  - 永続ルールは専用のガイドファイルに簡潔に記載し、肥大化を避ける。
  - 権限設定・CLI・サブエージェント/役割分担で作業を分割する。
  - カスタムコマンドやサブエージェント定義は frontmatter でメタ情報を明示する。
  - セッション管理（/clear, /rewind）で文脈汚染を防ぐ。

## Microsoft — Azure OpenAI Prompt Engineering

- URL: https://learn.microsoft.com/azure/ai-services/openai/concepts/prompt-engineering
- 要点:
  - GPT 系向けの基本手法（推論モデル向けは別ガイド）。
  - 指示・主コンテンツ・例示・キュー・補助情報を組み立てる。
  - 明確な指示、出力形式の指定、タスク分割が効果的。
  - 順序・反復（recency bias）を意識し、必要なら指示を再掲する。
  - 事実性が重要な用途は「根拠データを同梱」してグラウンディングする。
  - 具体性・記述性・逃げ道（not found など）を用意する。

## Google Cloud — Prompt Engineering Tips

- URL: https://cloud.google.com/blog/products/application-development/five-best-practices-for-prompt-engineering
- 要点:
  - モデルの強み/弱みとバイアスを理解する。
  - 具体的・文脈付きの指示にする。
  - 例示やペルソナ指定で出力を安定化する。
  - 反復・試行で最適化し、段階分解で複雑タスクを解く。

## Amazon Bedrock — Prompt Engineering Guidelines

- URL: https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-engineering-guidelines.html
- 要点:
  - プロンプトは LLM への入力で、指示やコンテキストが結果に直結する。
  - プロンプトは「指示」「コンテンツ」「例示」などの構成要素を意識する。
  - 例示（few-shot）で期待動作を示すと安定する。
  - 幻覚対策として、プロンプト最適化・関連データの追加・モデル選択を検討する。

## Prompt Engineering Guide

- URL: https://www.promptingguide.ai/
- 要点:
  - 基礎〜高度までの技法カタログ（few-shot, CoT, ReAct, prompt chaining, RAG など）。
  - AIエージェント/コンテキストエンジニアリングの学習導線がある。
  - 手法の俯瞰・用語整理の参照先として使う。

## IBM Think — Prompt Engineering

- URL: https://www.ibm.com/think/prompt-engineering
- 要点:
  - プロンプト設計は生成AI活用のコアスキルとして位置付け。
  - コンテキスト設計（RAG/要約/構造化入力）を重視する。
  - 実例・チュートリアル・ツールを通じた学習導線を提供。

---

## 運用ルール（共通）

- 参照 URL は削除しない。
- 重要事項は「短い要点」に落とし、詳細は元ページで確認する。
- ガイドラインが更新されるため、定期的に見直す。

---

## 実務テンプレ（汎用）

### 1) プロンプト構成テンプレ

- 目的（やること/やらないこと）
- 入力（対象データ/前提）
- 出力形式（箇条書き/JSON/表/長さ制限）
- 例示（1〜3件の代表例）
- 検証基準（テスト/期待出力/禁止事項）
- 追加文脈（必要最小限の補足情報）

### 2) 検証基準テンプレ

- 検証方法: 例）テスト名、コマンド、手順
- 期待結果: 例）「テストが全通過」「スクショで差分ゼロ」
- 失敗時対応: 例）再試行/原因特定/差分報告

### 3) コンテキスト運用チェックリスト

- 高シグナル最小集合になっているか
- 指示は具体すぎず曖昧すぎないか（適正粒度）
- 例示は代表例に絞れているか
- 長期タスクは compaction/ノート/サブエージェントを併用しているか
- 事前取得とジャストインタイム取得の使い分けができているか

---

## 参照ソース

- https://platform.openai.com/docs/guides/prompt-engineering
- https://learn.microsoft.com/azure/ai-services/openai/concepts/prompt-engineering
- https://code.claude.com/docs/en/best-practices
- https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
