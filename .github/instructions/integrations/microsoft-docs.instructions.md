---
description: "Microsoft / Azure / M365 の仕様・手順・制限・エラー検索の参照優先順位と出典 URL 明記ルール"
applyTo: "**"
---
<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-06-14 -->

# Microsoft Documentation Instructions

Microsoft / Azure / Microsoft 365 に関する回答やコード生成では、最新の公式情報を優先して確認する。

## When to Use

- 使う: Microsoft / Azure / M365 の仕様・手順・制限・エラー・コード例を扱うとき
- 使う: GA / Preview / Retirement / API バージョンを明示したいとき
- 使わない: 一般的な Web 検索や他社ドキュメントを扱うとき → `web-search` を使う
- 使わない: Microsoft 365 内のメール、会議、ファイルなど個人/組織データの所在確認

## Core Rules

- Microsoft / Azure の仕様、手順、制限、エラー、コード例は、記憶だけで答えず microsoftdocs MCP を使う。
- 回答や成果物には参照元 URL を入れる。
- API バージョン、SDK バージョン、GA / Preview / Retirement の状態が関係する場合は明記する。
- ライセンス要件を述べるときは、法人向け add-on 条件と個人向けプラン条件（Personal / Family / Premium 等）が同ページに併記されていないか確認し、「必須」を一括断定しない。
- 製品名、ブランド名、ポータル名、ロール名が論点なら、**現在の正式名称** を microsoftdocs MCP で確認する。旧称と現行名が混在する時期は、古い呼び方をそのまま正とみなさず、必要なら `旧称` を併記する。
- Microsoft / Azure 関連コードを生成するときは `mcp_microsoft_lea_microsoft_code_sample_search` を優先して公式サンプルを確認する。
- 新機能、廃止予定、GA 時期は `mcp_releasecommun_get_recent_azure_updates` を使う。
- Microsoft Tech Community と Microsoft Developer Blog は **補助的な公式ソース**。発表、背景説明、実装補足、現場寄りのベストプラクティス、画像/図版の利用に使ってよい。ただし hard limit、正式サポート、必須要件の根拠にはせず、対応する Docs を正本にする。画像/図版は再利用条件に反しない範囲で使い、不明な場合は転載せず説明文やオリジナル図で代替する。

## Tool Selection

| Need | Tool |
| --- | --- |
| 仕様、手順、制限、トラブルシュート | `mcp_microsoft_lea_microsoft_docs_search` |
| 公式コード例 | `mcp_microsoft_lea_microsoft_code_sample_search` |
| 検索結果だけでは足りない詳細手順 | `mcp_microsoft_lea_microsoft_docs_fetch` |
| Microsoft Tech Community / Microsoft Developer Blog の既知 URL 本文取得 | `fetch_webpage` |
| Azure の新機能、廃止予定、GA / Preview（一覧） | `mcp_releasecommun_get_recent_azure_updates` |
| Azure Updates の個別詳細 | `mcp_releasecommun_get_azure_update_by_id` |
| Microsoft 365 roadmap（一覧・個別詳細） | `activate_m365_roadmap_tools` でロードした Roadmap tools |

## Response Requirements

- 日本語で回答する。技術用語は公式 Docs の日本語版表記を優先し、定訳がない場合は英語のまま使う。
- 公式 Docs を参照した場合は、文末か「参照」欄に URL を出す。
- リージョン、提供可否、接続拠点、事業者対応が論点なら、可能なら **日本リージョン/適用範囲** を明記する。
- 公式情報が見つからない場合は、その不確実性を明記する。
- 非公式ブログや古い記憶だけを根拠に、仕様・制限・サポート状況を断定しない。
- microsoftdocs MCP の情報が不足するときだけ、公式 GitHub リポジトリや公式ブログを補助的に使う。
- 公式 Docs 内で新旧名称が混在している場合は、**現行の overview / what-is / getting-started ページ** を優先し、古い how-to や classic ドキュメントだけで正式名称を決めない。

## Query Tips

- microsoftdocs MCP への検索クエリは英語を優先する（日本語クエリよりヒット精度が高い）。回答は日本語にする。
- サービス名、機能名、エラー文、言語/SDK を検索語に入れる。
- 日本向け案件では、必要に応じて `Japan East`, `Japan West`, `Japan`, `Tokyo`, `Osaka`, `provider`, `peering location` などの語を検索語へ入れる。
- コード例は言語を明示する。例: `Azure Functions Python`, `Microsoft Graph TypeScript`。
- mrc-mcp (Azure Updates / M365 Roadmap) は OData filter で検索する。プロダクト名・ステータス・日付範囲を組み合わせて絞り込む。タイトル検索は `search` パラメータを使う。
- mrc-mcp は広い並列バッチより **1 件ずつ** を優先する。途中のユーザー入力や MCP 起動失敗で `Canceled` / `fetch failed` になり全件崩れやすい。1 件でも ID / タイトルが取れたら `*_by_id` で深掘り、取得済み evidence を先に成果物へ反映してから不足分だけ追う。

## Web Fetch Fallback

- Web ページ本文が必要なら `fetch_webpage` を優先する。
- `curl -sL` は日本語が文字化けする場合があるため、フォールバックとして使う。
- Microsoft Tech Community や Microsoft Developer Blog のような既知の公式ブログ URL も、`fetch_webpage` で取得してよい。

## URL Locale Handling

- `mcp_microsoft_lea_microsoft_docs_search` / `mcp_microsoft_lea_microsoft_code_sample_search` などの Microsoft Learn MCP は **ロケール非依存 URL**（例: `learn.microsoft.com/azure/...`）を返す。日本語回答や成果物に貼る前に必ず `learn.microsoft.com/ja-jp/azure/...` に置換する。
- ja-jp 版で HTTP 404 になる場合は **en-us に戻さない**。代わりに `mcp_microsoft_lea_microsoft_docs_search` を再実行し、`/concepts/`, `/how-to/`, `/quickstart/`, `/tutorial/`, `/concepts/{name}-reference` などのパス variant や後継ページ名を探す。
- URL を成果物（コード、ドキュメント、CSV、レポートなど）に埋め込んだ後は、`fetch_webpage` の HEAD レスポンスや HTTP HEAD で 200 を確認するまで「完了」と言わない。
- Microsoft 公式ドキュメントは GA / Preview / Retirement のタイミングで URL 構造が改編されることがある。記憶や過去回答に頼らず、毎回 `mcp_microsoft_lea_microsoft_docs_search` で最新パスを取り直す。

