---
description: "Microsoft / Azure / M365 の仕様・手順・制限・エラー検索の参照優先順位と出典 URL 明記ルール"
applyTo: "**"
---
<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-10-14 -->

# Microsoft Documentation Instructions

Microsoft / Azure / Microsoft 365 に関する回答やコード生成では、最新の公式情報を優先して確認する。

## When to Use

- 使う: Microsoft / Azure / M365 の仕様・手順・制限・エラー・コード例を扱うとき
- 使う: GA / Preview / Retirement / API バージョンを明示したいとき
- 使わない: 一般的な Web 検索や他社ドキュメントを扱うとき → `web-search` を使う
- 使わない: Microsoft 365 内のメール、会議、ファイルなど個人/組織データの所在確認

## Core Rules

- Microsoft / Azure の仕様、手順、制限、エラー、コード例は、記憶だけで答えず microsoftdocs MCP を使う。
- 回答や成果物には参照元 URL を入れ、API / SDK バージョンや GA / Preview / Retirement が関係する場合は状態も明記する。
- ライセンス要件を述べるときは、法人向け add-on 条件と個人向けプラン条件（Personal / Family / Premium 等）が同ページに併記されていないか確認し、「必須」を一括断定しない。
- 製品名、ブランド名、ポータル名、ロール名が論点なら、**現在の正式名称** を microsoftdocs MCP で確認する。新旧名称が混在する場合は、現行の overview / what-is / getting-started を優先し、古い how-to や classic ページだけで正式名称を決めない。必要なら `旧称` を併記する。
- Microsoft / Azure 関連コードを生成するときは Microsoft Learn MCP の `microsoft_code_sample_search` を優先して公式サンプルを確認する。
- 新機能、廃止予定、GA 時期は `mrc-mcp` の `get_recent_azure_updates` を使う。
- Microsoft Tech Community と Microsoft Developer Blog は **補助的な公式ソース**。発表、背景説明、実装補足、現場寄りのベストプラクティス、画像/図版の利用に使ってよい。ただし hard limit、正式サポート、必須要件の根拠にはせず、対応する Docs を正本にする。画像/図版は再利用条件に反しない範囲で使い、不明な場合は転載せず説明文やオリジナル図で代替する。

## Tool Selection

| Need | Tool |
| --- | --- |
| 仕様、手順、制限、トラブルシュート | Microsoft Learn MCP の `microsoft_docs_search` |
| 公式コード例 | Microsoft Learn MCP の `microsoft_code_sample_search` |
| 検索結果だけでは足りない詳細手順 | Microsoft Learn MCP の `microsoft_docs_fetch` |
| Microsoft Tech Community / Microsoft Developer Blog の既知 URL 本文取得 | `web_fetch` |
| Azure の新機能、廃止予定、GA / Preview（一覧） | `mrc-mcp` の `get_recent_azure_updates` |
| Azure Updates の個別詳細 | `mrc-mcp` の `get_azure_update_by_id` |
| Microsoft 365 roadmap（一覧・個別詳細） | `mrc-mcp` の `get_recent_m365_roadmaps` / `get_m365_roadmap_by_id` |

## Response Requirements

- 日本語で回答し、ユーザーが別言語を使った場合は合わせる。日本語の技術用語は公式 Docs の日本語版表記を優先し、定訳がない場合は英語のまま使う。
- リージョン、提供可否、接続拠点、事業者対応が論点なら、可能なら **日本リージョン/適用範囲** を明記する。
- 公式情報が見つからない場合は不確実性を明記する。公式 GitHub は MCP の情報が不足するときだけ補助的に使う。公式ブログは Core Rules の用途・制約に従う。

## Query Tips

- MCP の検索は英語を優先し、サービス名、機能名、エラー文、言語 / SDK を含める。
- 日本向け案件では、必要に応じて `Japan East`, `Japan West`, `Tokyo`, `Osaka`, `provider`, `peering location` などを加える。
- Azure Updates / M365 Roadmap はプロダクト、ステータス、日付範囲で絞り、タイトル検索には `search` を使う。
- mrc-mcp は広い並列バッチより **1 件ずつ** を優先する。途中のユーザー入力や MCP 起動失敗で `Canceled` / `fetch failed` になり全件崩れやすい。1 件でも ID / タイトルが取れたら `*_by_id` で深掘り、取得済み evidence を先に成果物へ反映してから不足分だけ追う。

## URL Locale Handling

- Microsoft Learn MCP（`microsoft_docs_search` / `microsoft_code_sample_search` など）は **ロケール非依存 URL**（例: `learn.microsoft.com/azure/...`）を返す。日本語の回答・成果物に貼る前に必ず `learn.microsoft.com/ja-jp/azure/...` に置換する。英語の回答・成果物にはこの置換を適用せず、検索・取得で確認した URL を使う。
- ja-jp 版で HTTP 404 になる場合は **en-us に戻さない**。代わりに `microsoft_docs_search` を再実行し、`/concepts/`, `/how-to/`, `/quickstart/`, `/tutorial/`, `/concepts/{name}-reference` などのパス variant や後継ページ名を探す。
- URL を成果物（コード、ドキュメント、CSV、レポートなど）に埋め込んだ後は到達性を確認する。
- Microsoft 公式ドキュメントは GA / Preview / Retirement のタイミングで URL 構造が改編されることがある。記憶や過去回答に頼らず、毎回 `microsoft_docs_search` で最新パスを取り直す。

