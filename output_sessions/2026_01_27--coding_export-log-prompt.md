---
type: coding
started_at: 2026-01-27T22:00:00
ended_at: 2026-01-27T22:40:27
duration_minutes: 40
tools_used: [list_dir, read_file, semantic_search, grep_search, create_file, replace_string_in_file, run_in_terminal]
outcome_status: partial
---

# 汎用作業ログプロンプトの作成

## Summary

既存の `review-session-export-md.prompt.md`（成果物特化）とは別に、試行錯誤のプロセスも適度に圧縮して記録する汎用作業ログプロンプト `export-log.prompt.md` を新規作成した。その後、命名規則の検討と終了時刻取得機能を追加。

## Timeline

### 22:00 - 要件整理

- ユーザー要望: 大量の試行錯誤を適度にまとめたい
- 既存プロンプトの調査開始
- 関連ファイルを確認:
  - [review-session-export-md.prompt.md](.github/prompts/review-session-export-md.prompt.md)
  - [review-retrospective-learnings.prompt.md](.github/prompts/review-retrospective-learnings.prompt.md)
  - [wrap-up-work.prompt.md](.github/prompts/wrap-up-work.prompt.md)

### 22:10 - 設計フェーズ（3回の計画改訂で集約）

- 初回計画: セッション作業ログ用プロンプト作成
- 改訂1: 汎用性追加（他AI読込・ブログ用途）
- 改訂2: 既存ファイル処理ロジック追加
- **最終仕様**:
  - セッションタイプ自動判定（coding/research/debug/design/discussion）
  - メタデータ自動抽出（時刻・ツール・成果ステータス）
  - 試行錯誤3回以上で圧縮
  - 既存ファイルへの追記対応

### 22:20 - 実装

- [export-log.prompt.md](.github/prompts/export-log.prompt.md) を新規作成
- YAML frontmatter + 構造化 Markdown フォーマット定義
- 圧縮ルール・ファイル処理ロジックを Premises に明文化

### 22:25 - リネーム

- `session-work-log.prompt.md` → `export-log.prompt.md` に変更
- [AGENTS.md](AGENTS.md) の Prompts テーブルを更新

### 22:30 - 追加機能

- `ended_at` を PowerShell コマンドで取得する機能を追加
- プロンプトファイルの命名規則を確認（混在状態を発見）

### 22:35 - 出力ファイル命名規則の検討（未確定）

- 日付フォーマット案: `YYYY-MM-DD` / `YYYYMMDD` / `YYYY_MM_DD`
- 区切り文字案: `_` / `-` / `--`
- セッション名案: `{type}-{topic}` / `{topic}` / `{type}_{topic}`
- ユーザー選択: 全部C → 確認待ち

## Key Learnings

- 試行錯誤の圧縮閾値は「3回以上」が妥当（ユーザー確認済み）
- AI可読性には YAML frontmatter + 一貫した見出し階層が重要
- 既存プロンプトとの差別化: 成果物 vs プロセス記録
- 終了時刻は `Get-Date` コマンドで正確に取得可能
- プロンプトファイル命名規則は現状混在（ハイフン/アンダースコア）

## Commands & Code

```powershell
# ファイルリネーム
Move-Item "session-work-log.prompt.md" "export-log.prompt.md"

# 現在時刻取得（ended_at用）
Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
```

## References

- [Anthropic Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) - 構造化ノートテイキングの参考

## Next Steps

- [ ] 出力ファイル命名規則を確定（全部C案の確認待ち）
- [ ] 確定後、[export-log.prompt.md](.github/prompts/export-log.prompt.md) を更新
- [ ] 出力を別AIセッションに読み込ませて理解度テスト
