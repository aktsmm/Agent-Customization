---
description: "Microsoft / Azure / Microsoft 365 の仕様・手順・制限・エラー・コード例を扱うときに使う。microsoftdocs MCP / mrc-mcp (Azure Updates / M365 Roadmap) を優先し、参照元 URL を明記するためのルール"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Microsoft Documentation Instructions

Microsoft / Azure / Microsoft 365 に関する回答やコード生成では、最新の公式情報を優先して確認する。

## When to Use

- 使う: Microsoft / Azure / M365 の仕様・手順・制限・エラー・コード例を扱うとき
- 使う: GA / Preview / Retirement / API バージョンを明示したいとき
- 使わない: 一般的な Web 検索や他社ドキュメントを扱うとき → `web-search` を使う

## Core Rules

- Microsoft / Azure の仕様、手順、制限、エラー、コード例は、記憶だけで答えず microsoftdocs MCP を使う。
- 回答や成果物には参照元 URL を入れる。
- API バージョン、SDK バージョン、GA / Preview / Retirement の状態が関係する場合は明記する。
- Microsoft / Azure 関連コードを生成するときは `mcp_microsoftdocs_microsoft_code_sample_search` を優先して公式サンプルを確認する。
- 新機能、廃止予定、GA 時期は `mcp_mrc-mcp_get_recent_azure_updates` を使う。

## Tool Selection

| Need | Tool |
| --- | --- |
| 仕様、手順、制限、トラブルシュート | `mcp_microsoftdocs_microsoft_docs_search` |
| 公式コード例 | `mcp_microsoftdocs_microsoft_code_sample_search` |
| 検索結果だけでは足りない詳細手順 | `mcp_microsoftdocs_microsoft_docs_fetch` |
| Azure の新機能、廃止予定、GA / Preview（一覧） | `mcp_mrc-mcp_get_recent_azure_updates` |
| Azure Updates の個別詳細 | `mcp_mrc-mcp_get_azure_update_by_id` |
| Microsoft 365 roadmap（一覧） | `mcp_mrc-mcp_get_recent_m365_roadmaps` |
| Microsoft 365 roadmap の個別詳細 | `mcp_mrc-mcp_get_m365_roadmap_by_id` |
| Microsoft 365 内のメール、会議、ファイル | `mcp_workiq_ask_work_iq` |

## Response Requirements

- 日本語で回答する。技術用語は公式 Docs の日本語版表記を優先し、定訳がない場合は英語のまま使う。
- 公式 Docs を参照した場合は、文末か「参照」欄に URL を出す。
- 公式情報が見つからない場合は、その不確実性を明記する。
- 非公式ブログや古い記憶だけを根拠に、仕様・制限・サポート状況を断定しない。
- microsoftdocs MCP の情報が不足するときだけ、公式 GitHub リポジトリや公式ブログを補助的に使う。

## Query Tips

- microsoftdocs MCP への検索クエリは英語を優先する（日本語クエリよりヒット精度が高い）。回答は日本語にする。
- サービス名、機能名、エラー文、言語/SDK を検索語に入れる。
- コード例は言語を明示する。例: `Azure Functions Python`, `Microsoft Graph TypeScript`。
- mrc-mcp (Azure Updates / M365 Roadmap) は OData filter で検索する。プロダクト名・ステータス・日付範囲を組み合わせて絞り込む。タイトル検索は `search` パラメータを使う。

## Web Fetch Fallback

- Web ページ本文が必要なら `fetch_webpage` を優先する。
- `curl -sL` は日本語が文字化けする場合があるため、フォールバックとして使う。

## URL Locale Handling

- `mcp_microsoftdocs_microsoft_docs_search` / `mcp_microsoftdocs_microsoft_code_sample_search` などの microsoftdocs MCP は **ロケール非依存 URL**（例: `learn.microsoft.com/azure/...`）を返す。日本語回答や成果物に貼る前に必ず `learn.microsoft.com/ja-jp/azure/...` に置換する。
- ja-jp 版で HTTP 404 になる場合は **en-us に戻さない**。代わりに `mcp_microsoftdocs_microsoft_docs_search` を再実行し、`/concepts/`, `/how-to/`, `/quickstart/`, `/tutorial/`, `/concepts/{name}-reference` などのパス variant や後継ページ名を探す。
- URL を成果物（コード、ドキュメント、CSV、レポートなど）に埋め込んだ後は、`fetch_webpage` の HEAD レスポンスや HTTP HEAD で 200 を確認するまで「完了」と言わない。
- Microsoft 公式ドキュメントは GA / Preview / Retirement のタイミングで URL 構造が改編されることがある。記憶や過去回答に頼らず、毎回 `mcp_microsoftdocs_microsoft_docs_search` で最新パスを取り直す。

