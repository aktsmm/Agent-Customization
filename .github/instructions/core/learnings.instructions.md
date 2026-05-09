---
applyTo: "**"
---

<!-- description: Learnings 蓄積ルール（出力先・フォーマット・読み書き共通） -->

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Learnings 蓄積ルール

修正・レビュー・デバッグ等で得た教訓を構造化して蓄積する共通ルール。
`code-fix-error.prompt.md`、`code-review.prompt.md` 等から参照される。

## 出力先

| 条件                        | 出力先                               |
| --------------------------- | ------------------------------------ |
| デフォルト                  | `.github/review-learnings.md`        |
| 「workspace」「ローカル」等 | `{workspace}/review-learnings.md`    |
| パス指定あり                | 指定パス                             |
| ファイルが存在しない場合    | フォーマットに従って**新規作成**する |

## 記録ルール

- **記録対象**: 今後のレビュー・修正で再利用できる知見のみ
- **書かない場合**: 新しい教訓が無ければファイルに触れない
- **些末な修正**（typo 等）は記録不要
- **採番**: 既存エントリの続き（U3 があれば次は U4）
- **重複禁止**: 既存と同じ知見は追加しない（既存を補強する場合は追記）

## フォーマット

```markdown
# Review Learnings

## Universal（汎用 — 他プロジェクトでも使える）

### U1: <タイトル>

- **Tags**: `<観点>` `<観点>`
- **Added**: YYYY-MM-DD
- **Evidence**: <何が起きたか（具体的な状況）>
- **Action**: <今後どうすべきか（具体的な対策）>

## Project-specific（このワークスペース固有）

### P1: <タイトル>

- **Tags**: `<観点>` `<観点>`
- **Added**: YYYY-MM-DD
- **Evidence**: <何が起きたか>
- **Action**: <今後どうすべきか>
```

## 読み込み

Learnings を活用するプロンプトは、コンテキスト収集フェーズで以下を **存在する場合のみ** 読む：

1. `AGENTS.md` の Learnings セクション（あれば）
2. `.github/review-learnings.md`（あれば）
