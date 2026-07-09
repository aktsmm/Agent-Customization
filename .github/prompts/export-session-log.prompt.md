---
name: "export-session-log"
description: "Work timeline: セッション内容を作業ログ・ブログネタ向けに構造化して出力。Use when: timeline, 作業ログ, ブログ下書き。対話再現は export-copilot-session-dialogue、再利用知見は export-knowledge を使う"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# export session log

セッション内容を構造化されたMarkdownにエクスポートします。

## 出力パス

出力先の優先順は、ユーザー指定 > 環境変数 > workspace/local > 確認。

- **通常**: `$env:EXPORT_SESSION_LOG_DIR/YYYYMMDD-NN--{topic}.md`。未設定なら `{workspace}/output_sessions/YYYYMMDD-NN--{topic}.md`。workspace が無ければ確認する
- **ブログ**: `$env:EXPORT_SESSION_BLOG_DIR/YYYYMMDD-NN--{topic}.md`。未設定なら workspace に `drafts_topic/` が存在する場合だけ `{workspace}/drafts_topic/YYYYMMDD-NN--{topic}.md` を使い、それ以外は確認する
  - トリガー: `ブログ`, `blog`, `記事`, `article`, `post`, `Zenn`, `Qiita`, `はてな`
- **NN**: 同日の連番（01, 02, 03...）。出力先に同日ファイルが既にあれば次の番号を採番する
- 出力先 root を環境変数または既存 workspace から解決できなければ、作成前に確認する

## 出力フォーマット

````markdown
---
type: coding|research|debug|design|discussion
exported_at: { エクスポート時刻 }
tools_used: [tool1, tool2]
outcome_status: success|partial|failed
---

# {Session Title}

## Summary

{1-2文の概要}

## Timeline

### Phase N - {フェーズ名}

- {作業内容}
- Modified: [file](file#L10)

## Key Learnings

- {発見・学び}

## Commands & Code

```{lang}
{有用なコード}
```
````

## References

- Title - https://example.com/article
- Related File - C:/work/repo/path/to/file.md

## Next Steps

- [ ] {次のタスク}

## ルール

- エクスポート前に `Get-Date -Format "yyyy-MM-ddTHH:mm:ss"` を実行し、その結果を `exported_at` に使用する
- Timeline のヘッダーは時刻ではなく `Phase N - {フェーズ名}` の形式にする（正確な時刻が不明なため）
- 同日同トピックのファイルが存在 → 追記
- 試行錯誤は圧縮（3+回 → "N attempts" + 最終解決）
- Web / Docs / ブログ / 外部ページを使ったセッションでは `## References` を省略せず、**実際に結論や説明に使った出典** をタイトル付き URL で列挙する
- 外部情報に基づく要約、可否判断、仕様説明、比較は、本文だけで完結させず `## References` に対応する出典 URL を残す
- ブログ向け出力では、出典が 1 件でもある場合は URL だけでなくページタイトルも併記する
- 使っていない検索候補や本文に反映していない URL は無理に列挙しない
- 他ワークスペースのファイルや別 repo のローカル資料を参照したセッションでは、`## References` に **関連ファイルのパス** も残す
- 関連ファイルのパスは、説明に使ったファイル、判断根拠に使ったファイル、次の作業で開き直すと有用なファイルを優先して列挙する
- 関連ファイルが現在の出力先と別ワークスペースにある場合でも省略せず、必要なら絶対パスまたは十分に特定できるパスを書く
- URL とファイルパスが両方ある場合は両方残し、`## References` を「出典 URL + 関連ファイル」の索引として使う
