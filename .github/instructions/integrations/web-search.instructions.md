---
description: "Web 検索とページ取得の使い分け（Brave、DuckDuckGo HTML、Copilot CLI web_search、公式 Docs 優先）"
applyTo: "**"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Web Search Instructions

Web 検索、ページ取得、最新情報確認、出典付き調査を行うときの共通ルール。

## Core Rules

- Search と Fetch を混同しない。Search は候補 URL を探す行為、Fetch は既知 URL の本文を読む行為として扱う。
- 検索結果のスニペットだけで仕様、制限、サポート状況、廃止、価格、セキュリティ事項を断定しない。重要な結論は元ページを取得して確認する。
- 公式ドキュメント、公式ブログ、公式リリースノート、標準仕様を優先する。非公式ブログや Q&A は補助根拠に留める。
- 最新性が重要な話題では、検索・取得した日付と情報の限界を明記する。
- 外部情報を根拠にした回答では、URL を明記する。

## Provider Priority

1. Microsoft / Azure / Microsoft 365 関連は `microsoftdocs/*` を優先する。新機能、GA、Preview、Retirement は Azure Updates / M365 roadmap 系ツールを使う。
2. 汎用 Web 検索は `brave-search/*` を第一候補にする。レスポンス、構造化結果、再現性のバランスが良い。
3. 既知の公式 URL がある場合は、検索を挟まず `web/fetch` や `fetch_webpage` で直接取得してよい。
4. Brave が失敗、429、または利用不可の場合は DuckDuckGo HTML を fetch fallback として使う。
5. それでも検索候補が必要で、terminal tool が許可されている場合だけ、Copilot CLI `web_search` を read-only fallback として使う。

## DuckDuckGo HTML Fallback

Brave が使えない場合の候補 URL 収集に使う。

```text
https://html.duckduckgo.com/html/?q=<URL-encoded-query>
```

- `fetch_webpage` / `web/fetch` で HTML 版を取得する。
- API キー不要で便利だが、HTML 構造変更、取得制限、結果品質のばらつきはあり得る。
- 重要な判断には、DuckDuckGo 結果から選んだ元ページを別途 Fetch して確認する。

## Copilot CLI web_search Fallback

Terminal tool が利用可能で、read-only な URL 収集・下調べとして安全な場合だけ使う。

```powershell
copilot -p "<query>。URL のみ、1行1件で返して。" `
  --allow-all-tools `
  --allow-all-urls `
  --available-tools web_search `
  --silent
```

- Copilot CLI fallback は API キー追加なしで使える保険として扱う。
- CLI 起動のオーバーヘッドがあるため、Brave より優先しない。
- terminal 利用は Web 検索 fallback に限定し、build / test / install / deploy / format / mutation コマンドには使わない。
- URL だけが必要なときは「URL のみ、1行1件」と明示する。

## Reporting

- Web 検索を使った場合は、使用した provider と fallback の有無を簡潔に示す。
- 検索できず Fetch だけ行った場合は、「Web 検索」ではなく「既知 URL の取得」と表現する。
- 重要な主張は、可能なら 2 件以上の独立した信頼できるソースで確認する。
- 検索プロバイダーが失敗した場合は、失敗した方法、代替した方法、残る不確実性を短く報告する。