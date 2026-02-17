---
description: 作業セッションログ（AI可読・構造化）
---

<!-- syncToGlobal: true -->

# Export Session Log

セッション内容を構造化されたMarkdownにエクスポートします。

## 出力パス

- **通常**: `/output_sessions/YYYYMMDD-NN--{topic}.md`
- **ブログ**: `D:\11_My_Personal_Blog\drafts_topic\YYYYMMDD-NN--{topic}.md`
  - トリガー: `ブログ`, `blog`, `記事`, `article`, `post`, `Zenn`, `Qiita`, `はてな`
- **NN**: 同日の連番（01, 02, 03...）。出力先に同日ファイルが既にあれば次の番号を採番する

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

- [Title](URL)

## Next Steps

- [ ] {次のタスク}

```

## ルール

- エクスポート前に `Get-Date -Format "yyyy-MM-ddTHH:mm:ss"` を実行し、その結果を `exported_at` に使用する
- Timeline のヘッダーは時刻ではなく `Phase N - {フェーズ名}` の形式にする（正確な時刻が不明なため）
- 同日同トピックのファイルが存在 → 追記
- 試行錯誤は圧縮（3+回 → "N attempts" + 最終解決）
```
