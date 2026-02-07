---
description: セッション中のGitHub Copilot/MCP/エージェント関連の知見を構造化してD:\03.5_GHC_Researchにエクスポート
---

<!-- syncToGlobal: true -->

# Knowledge Export

このセッションで得られた知見を構造化してエクスポートします。

## 出力先

`D:\03.5_GHC_Research\_output-knowledge\{category}\`

## カテゴリ（フォルダ名）

prompts / agents / workflows / subagent / context / mcp / skills / debugging / automation / evaluation / vscode-settings / lessons-learned / templates

## 手順

1. セッションから知見を抽出（技術的発見、エラー解決、作成物、参照URL）
2. カテゴリを1つ選定、他はタグに
3. 以下の形式でMarkdownファイルを作成:

```markdown
---
title: "知見のタイトル"
datetime: { エクスポート時刻 }
primaryCategory: mcp
tags: [debugging, error-handling]
references:
  - url: https://example.com/doc
    title: ドキュメントタイトル
---

## 知見

（本文）

## 具体例

（コード例があれば）
```

4. ファイル名: `{YYYYMMDD}-{topic-slug}.md`
5. インデックス更新: `D:\03.5_GHC_Research\_output-knowledge\_index\knowledge-index.json` に追記

## ルール

- エクスポート前に `Get-Date -Format "yyyy-MM-ddTHH:mm:ss"` を実行し、その結果を `datetime` に使用する
