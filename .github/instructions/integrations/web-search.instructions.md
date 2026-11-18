---
description: "Web 検索・ページ取得の tool 選択と参照優先順位ルール"
applyTo: "**"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-10-28 -->

# Web Search Instructions

Web 検索、ページ取得、最新情報確認、出典付き調査を行うときの共通ルール。

## When to Use

- 使う: 一般的な Web 検索やページ取得が必要なとき
- 使う: 公式 Docs と並んで他社記事・コミュニティ情報・リリースノートを参照したいとき
- 使わない: Microsoft / Azure / M365 中心の調査 → `microsoft-docs` を使う

## Core Rules

- Search と Fetch を混同しない。Search は候補 URL を探す行為、Fetch は既知 URL の本文を読む行為として扱う。
- 検索結果のスニペットだけで仕様、制限、サポート状況、廃止、価格、セキュリティ事項を断定しない。重要な結論は元ページを取得して確認する。他の AI の要約やまとめ記事にある docs の引用・提供状況も同様に、原典で引用文を検索してから使い、見つからなければ「確認できず」とする。
- 公式ドキュメント、公式ブログ、公式リリースノート、標準仕様を優先する。非公式ブログや Q&A は補助根拠に留める。
- URL 到達性チェックで `HEAD` が 400 / 405 でも即リンク切れと断定しない。`GET` で再確認してから判定する（短縮 URL や一部サイトは HEAD 非対応の場合がある）。
- 静的取得（`web_fetch`・HTTP の本文）に出ない UI 部品（登録欄・ログイン後の表示・スクリプト描画）は「無い」の証拠にしない。実ブラウザの描画後の画面で確認してから報告する（イベントページの登録欄は、本文取得では出なかったが実画面には表示されていた）。
- 記事サイトの HTML から本文が取れないとき（広告スクリプトに埋もれる等）は、公開 API を試す（例: Qiita の `https://qiita.com/api/v2/items/<id>`、認証なしで全文が取れた）。
- 最新性が重要な話題では、検索・取得した日付と情報の限界を明記する。
- 外部情報を根拠にした回答では、URL を明記する。

## Provider Priority

1. GitHub / GitHub Enterprise の機能、API、リポジトリ、Issue / PR、Actions、セキュリティ機能を調べるときは GitHub MCP を第一候補にする。公式 Docs は `github_support_docs_search`、リポジトリや Issue / PR の調査は対応する GitHub MCP tool を使い、MCP または必要な toolset が利用できない場合だけ GitHub 公式 URL の直接取得、次に汎用 Web 検索へ進む。変更を伴う操作やローカル未展開の軽微な取得は `gh`（`gh api`）を使う。
2. Microsoft / Azure / Microsoft 365 関連は Microsoft Learn MCP（`microsoft_docs_search` など）を優先する。新機能、GA、Preview、Retirement は `mrc-mcp` の Azure Updates / M365 roadmap ツールを使う。
3. OpenAI / ChatGPT / Codex / OpenAI API 関連は `openaiDeveloperDocs`（OpenAI Docs MCP）を優先する。利用不可または公式 Docs 外の情報が必要な場合は、OpenAI 公式 URL を直接取得してから汎用 Web 検索へ進む。
4. Anthropic / Claude / Claude Code / Anthropic API 関連は、Platform Docs には `anthropicDocs`、Claude Code Docs には `claudeCodeDocs` を優先する。利用不可または公式 Docs 外の情報が必要な場合は、Anthropic 公式 URL を直接取得してから汎用 Web 検索へ進む。
5. 公開 X 投稿・検索は FxTwitter API v2（X Corp. 非公式の第三者サービス）を優先してよい。既知投稿は `/2/status/{id}`、検索は `/2/search?q=<URL-encoded-query>&feed=latest&count=<1-100>`（次ページは `cursor.bottom`）で `code: 200` だけ採用する。`since:` / `until:`（YYYY-MM-DD）と `from:<handle>` が使えるが、実応答は `count=100` でも約 20 件で止まるため、期間・handle・キーワードで分割して再検索し、ハッシュタグ検索だけで網羅と判断しない。人気投稿も `latest` で集めて反応数でローカル sort し、反応数は候補発見にのみ使う。認証情報を渡さず、非公開・削除済み・大量継続収集に使わない。出典は原 X URL とリンク先の一次情報で確認する。
6. 汎用 Web 検索は `brave-search` MCP（`brave_web_search` など）を優先する。失敗時は Fallbacks に従う。
7. 既知の公式 URL がある場合は、検索を挟まず `web_fetch` で直接取得してよい。

## Fallbacks

Brave の 429 は、失敗した query を直列で 1 回だけ再試行する（並列実行直後も同じ）。429 が続くか Brave が利用不可なら DuckDuckGo HTML で候補 URL を集め、重要な判断は元ページを Fetch して確認する。

```text
https://html.duckduckgo.com/html/?q=<URL-encoded-query>
```

- Brave / DuckDuckGo で候補が足りない場合に限り、組み込みの `web_search` を read-only の URL 収集専用に使う。build / test / install / deploy / format / mutation には使わない。
- 既知 URL の Fetch がブロック、タイムアウト、または利用不可なら、PowerShell では `Invoke-WebRequest -Uri <url> -Method Get -OutFile <tmp> -PassThru` を第一候補にする。HTTP ステータス、リダイレクト先、保存した本文を同じ経路で確認できる。
- `Invoke-WebRequest` が失敗した場合は、`curl.exe -L --fail -o <tmp> <url>` を第二候補にする。TLS 検証を無効にするオプションは使わず、両方失敗した場合は未検証とする。
- 日本語ページ、大容量ページ、バイナリは標準出力へパイプせず、`-OutFile` または `-o` で一時ファイルへ保存する。UTF-8 と期待する本文、応答サイズ、本文終端を確認し、重要な取得では別経路のバイト数またはハッシュも照合して一時ファイルを削除する。
- フォールバック手順を追加・変更したタスクは、構文や diff だけで完了扱いにせず、実在ページでその経路を実行する。文字コードや応答サイズが論点なら、日本語ページと大容量ページを少なくとも 1 件ずつ試す。

## Reporting

- Web 検索を使った場合は、使用した provider と fallback の有無を簡潔に示す。
- 検索できず Fetch だけ行った場合は、「Web 検索」ではなく「既知 URL の取得」と表現する。
- 重要な主張は、可能なら 2 件以上の独立した信頼できるソースで確認する。
- 検索プロバイダーが失敗した場合は、失敗した方法、代替した方法、残る不確実性を短く報告する。