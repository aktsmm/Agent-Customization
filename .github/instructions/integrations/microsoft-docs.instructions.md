---
description: "Microsoft 公式ドキュメント参照（MCP ツール活用、ソース明記）"
applyTo: "**"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Microsoft Documentation Instructions

Microsoft / Azure / Microsoft 365 に関する回答やコード生成では、最新の公式情報を優先して確認する。

## Core Rules

- Microsoft / Azure の仕様、手順、制限、エラー、コード例は、記憶だけで答えず公式 Docs MCP を使う。
- 回答や成果物には参照元 URL を入れる。
- API バージョン、SDK バージョン、GA / Preview / Retirement の状態が関係する場合は明記する。
- Microsoft / Azure 関連コードを生成するときは `microsoft_code_sample_search` を優先して公式サンプルを確認する。
- 新機能、廃止予定、GA 時期は Azure Updates MCP を使う。

## Tool Selection

| Need | Tool |
| --- | --- |
| 仕様、手順、制限、トラブルシュート | `microsoft_docs_search` |
| 公式コード例 | `microsoft_code_sample_search` |
| 検索結果だけでは足りない詳細手順 | `microsoft_docs_fetch` |
| Azure の新機能、廃止予定、GA / Preview | `search_azure_updates` / `get_azure_update` |
| Microsoft 365 roadmap | `search_m365_roadmap` / `get_m365_update` |
| Microsoft 365 内のメール、会議、ファイル | `mcp_workiq_ask_work_iq` |

## Response Requirements

- 公式 Docs を参照した場合は、文末か「参照」欄に URL を出す。
- 公式情報が見つからない場合は、その不確実性を明記する。
- 非公式ブログや古い記憶だけを根拠に、仕様・制限・サポート状況を断定しない。
- Docs MCP の情報が不足するときだけ、公式 GitHub リポジトリや公式ブログを補助的に使う。

## Query Tips

- サービス名、機能名、エラー文、言語/SDK を検索語に入れる。
- コード例は言語を明示する。例: `Azure Functions Python`, `Microsoft Graph TypeScript`。
- 更新情報はサービス名と `GA`, `Preview`, `retirement`, `deprecated` などを組み合わせる。

## Web Fetch Fallback

- Web ページ本文が必要なら `fetch_webpage` を優先する。
- `curl -sL` は日本語が文字化けする場合があるため、フォールバックとして使う。
