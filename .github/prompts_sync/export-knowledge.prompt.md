---
description: セッション中のGitHub Copilot/MCP/エージェント関連の知見を構造化してD:\03.5_GHC_Researchにエクスポート
---

# Knowledge Export

このセッションで得られた知見を構造化してエクスポートします。

## 出力先
\D:\03.5_GHC_Research\_output-knowledge\

## 実行手順

### Step 1: タイムスタンプ取得
以下のコマンドを実行して現在時刻を取得してください：
\\\powershell
Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
\\\

### Step 2: セッション解析
このセッションの会話履歴を解析し、以下の観点で知見を抽出してください：

1. **新しく学んだこと** - 技術的な発見、ベストプラクティス
2. **解決した問題** - エラー対処、トラブルシューティング
3. **作成したもの** - テンプレート、スクリプト、設定
4. **参照したURL** - fetch_webpage、MCPサーバー経由、ユーザー共有URL

### Step 3: カテゴリ分類
各知見を以下の13カテゴリに分類してください。複数にまたがる場合はプライマリカテゴリを1つ選び、他はタグとして記録：

| カテゴリ | フォルダ名 | 内容 |
|---------|-----------|------|
| プロンプトエンジニアリング | \prompts/\ | 効果的なプロンプト構造、トークン削減、few-shot |
| エージェント設計 | \gents/\ | .agent.md構造、Role/Goals定義、Done Criteria |
| ワークフローパターン | \workflows/\ | Orchestrator-Workers、Prompt Chaining、Routing |
| runSubagent活用 | \subagent/\ | 委譲パターン、MUST/MANDATORY指示、並列実行 |
| Context Engineering | \context/\ | Context Rot対策、Compaction、コンテキスト最適化 |
| MCPサーバー活用 | \mcp/\ | Microsoft Docs、Azure Updates、カスタムMCP |
| スキル設計 | \skills/\ | SKILL.md構造、references整理、When to Use |
| デバッグ | \debugging/\ | エラーパターン、解決策、Fail Fast実装 |
| 自動化連携 | \utomation/\ | PowerShell/Python連携、外部ツール呼び出し |
| 評価/品質管理 | \valuation/\ | レビューチェックリスト、Gate設計、Feedback Loop |
| VS Code設定 | \scode-settings/\ | 拡張機能、settings.json、キーバインド |
| 失敗からの教訓 | \lessons-learned/\ | やらかし記録、リカバリ方法、再発防止 |
| 再利用テンプレート | \	emplates/\ | .agent.md、.prompt.md、SKILL.mdテンプレート |

### Step 4: 知見ファイル生成
各知見について以下の形式でMarkdownファイルを生成：

\\\markdown
---
title: "知見のタイトル"
datetime: 2026-01-29T18:53:34
primaryCategory: mcp
tags: [debugging, error-handling]
references:
  - url: https://example.com/doc
    title: ドキュメントタイトル
---

## 知見
ここに知見の本文を記述

## 具体例
コード例や設定例があれば記載

## 関連ファイル
- 関連するファイルへのリンク（あれば）
\\\

### Step 5: ファイル出力
以下の命名規則でファイルを作成：

\\\
{YYYYMMDD}-{topic-slug}.md

例: 20260129-mcp-error-handling.md
同一日に同じトピック: 20260129-mcp-error-handling_01.md
\\\

出力先: \D:\03.5_GHC_Research\_output-knowledge\{category}\{filename}\

### Step 6: インデックス更新
\D:\03.5_GHC_Research\_output-knowledge\_index\knowledge-index.json\ に以下の形式で追記：

\\\json
{
  "entries": [
    {
      "title": "知見のタイトル",
      "datetime": "2026-01-29T18:53:34",
      "primaryCategory": "mcp",
      "tags": ["debugging", "error-handling"],
      "filePath": "_output-knowledge/mcp/20260129-mcp-error-handling.md",
      "references": ["https://example.com/doc"]
    }
  ]
}
\\\

## 参照URL収集ルール

セッション中に以下のソースから参照URLを収集：
1. \etch_webpage\ ツールで取得したURL
2. MCPサーバー経由の情報出典（Microsoft Docs、Azure Updates等）
3. ユーザーがチャットで共有したURL
4. コード内コメントやドキュメント内リンク

## 同一セッションのマージルール

同じセッション内で同一トピックの知見が複数ある場合：
- 既存ファイルの内容を確認
- 新しい情報を適切にマージ
- \datetime\ は最新の時刻に更新
- \eferences\ は重複を除いて追加

