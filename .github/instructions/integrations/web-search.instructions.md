---
description: "Web 検索・ページ取得の tool 選択と参照優先順位ルール"
applyTo: "**"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-09-22 -->

# Web Search Instructions

Web 検索、ページ取得、最新情報確認、出典付き調査を行うときの共通ルール。

## When to Use

- 使う: 一般的な Web 検索やページ取得が必要なとき
- 使う: 公式 Docs と並んで他社記事・コミュニティ情報・リリースノートを参照したいとき
- 使わない: Microsoft / Azure / M365 中心の調査 → `microsoft-docs` を使う

## Core Rules

- Search と Fetch を混同しない。Search は候補 URL を探す行為、Fetch は既知 URL の本文を読む行為として扱う。
- 検索結果のスニペットだけで仕様、制限、サポート状況、廃止、価格、セキュリティ事項を断定しない。重要な結論は元ページを取得して確認する。
- 公式ドキュメント、公式ブログ、公式リリースノート、標準仕様を優先する。非公式ブログや Q&A は補助根拠に留める。
- URL 到達性チェックで `HEAD` が 400 / 405 でも即リンク切れと断定しない。`GET` で再確認してから判定する（短縮 URL や一部サイトは HEAD 非対応の場合がある）。
- 最新性が重要な話題では、検索・取得した日付と情報の限界を明記する。
- 外部情報を根拠にした回答では、URL を明記する。

## Provider Priority

1. GitHub / GitHub Enterprise の機能、API、リポジトリ、Issue / PR、Actions、セキュリティ機能を調べるときは GitHub MCP を第一候補にする。公式 Docs は `github_support_docs_search`、リポジトリや Issue / PR は対応する GitHub MCP tool を使い、MCP または必要な toolset が利用できない場合だけ GitHub 公式 URL の直接取得、次に汎用 Web 検索へ進む。
2. Microsoft / Azure / Microsoft 365 関連は `microsoftdocs/*` を優先する。新機能、GA、Preview、Retirement は Azure Updates / M365 roadmap 系ツールを使う。
3. OpenAI / ChatGPT / Codex / OpenAI API 関連は `openaiDeveloperDocs`（OpenAI Docs MCP）を優先する。利用不可または公式 Docs 外の情報が必要な場合は、OpenAI 公式 URL を直接取得してから汎用 Web 検索へ進む。
4. Anthropic / Claude / Claude Code / Anthropic API 関連は、Platform Docs には `anthropicDocs`、Claude Code Docs には `claudeCodeDocs` を優先する。利用不可または公式 Docs 外の情報が必要な場合は、Anthropic 公式 URL を直接取得してから汎用 Web 検索へ進む。
5. 既知の公開 X 投稿または X の明示クエリを調べるときは、FxTwitter API v2 の JSON 取得を優先してよい。ハッシュタグは必須ではなく、通常キーワード、`OR`、ドメイン、ハッシュタグを URL encode した `q` に渡せる。既知投稿は `/2/status/{id}`、検索は `/2/search?q=<URL-encoded-query>&feed=latest&count=<1-100>` を使い、`code: 200` の結果だけを採用する。次ページは `cursor.bottom` を `cursor` に渡す。
6. 人気投稿を探す場合も `feed=latest` で合意した時間窓・件数を先に収集し、重複排除後に `likes`、`reposts`、`views` でローカル sort する。反応数は候補発見に使い、採用根拠にはしない。本文、原 X URL、外部リンク先の repo / 記事 / 公式情報を別途確認する。
7. FxTwitter は X Corp. 非公式の第三者サービスとして扱う。認証情報を渡さず、非公開・削除済み投稿や大量・継続収集には使わない。取得失敗時は X の原 URL やブラウザ確認へ切り替え、出典には原 URL を示す。
8. 汎用 Web 検索は `brave-search/*` を第一候補にする。レスポンス、構造化結果、再現性のバランスが良い。
9. 既知の公式 URL がある場合は、検索を挟まず `web/fetch` や `fetch_webpage` で直接取得してよい。
10. Brave が 429 を返したら、失敗した query を直列で 1 回だけ再試行する。複数 query の並列実行直後は特にこの経路を使い、同じ 429 が続くか利用不可なら DuckDuckGo HTML へ切り替える。
11. それでも検索候補が必要で、terminal tool が許可されている場合だけ、Copilot CLI `web_search` を read-only fallback として使う。

## Fallbacks

Brave が使えない場合は、DuckDuckGo HTML から候補 URL を集め、重要な判断では取得した元ページを別途 Fetch して確認する。

```text
https://html.duckduckgo.com/html/?q=<URL-encoded-query>
```

それでも候補が必要な場合だけ、terminal tool で Copilot CLI `web_search` を URL 収集専用に使う。

```powershell
copilot -p "<query>。URL のみ、1行1件で返して。" `
  --allow-all-tools `
  --allow-all-urls `
  --available-tools web_search `
  --silent
```

- CLI fallback は Brave / DuckDuckGo より優先しない。terminal 利用は read-only な URL 収集に限定し、build / test / install / deploy / format / mutation には使わない。
- 既知 URL の Fetch がブロック、タイムアウト、または利用不可なら、PowerShell では `Invoke-WebRequest -Uri <url> -Method Get -OutFile <tmp> -PassThru` を第一候補にする。HTTP ステータス、リダイレクト先、保存した本文を同じ経路で確認できる。
- `Invoke-WebRequest` が失敗した場合は、`curl.exe -L --fail -o <tmp> <url>` を第二候補にする。TLS 検証を無効にするオプションは使わず、両方失敗した場合は未検証とする。
- 日本語ページ、大容量ページ、バイナリは標準出力へパイプせず、`-OutFile` または `-o` で一時ファイルへ保存する。UTF-8 と期待する本文、応答サイズ、本文終端を確認し、重要な取得では別経路のバイト数またはハッシュも照合して一時ファイルを削除する。
- フォールバック手順を追加・変更したタスクは、構文や diff だけで完了扱いにせず、実在ページでその経路を実行する。文字コードや応答サイズが論点なら、日本語ページと大容量ページを少なくとも 1 件ずつ試す。

## Reporting

- Web 検索を使った場合は、使用した provider と fallback の有無を簡潔に示す。
- 検索できず Fetch だけ行った場合は、「Web 検索」ではなく「既知 URL の取得」と表現する。
- 重要な主張は、可能なら 2 件以上の独立した信頼できるソースで確認する。
- 検索プロバイダーが失敗した場合は、失敗した方法、代替した方法、残る不確実性を短く報告する。