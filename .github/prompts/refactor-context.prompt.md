---
name: "refactor-context"
description: "指定スコープの instruction / prompt / agent をコンテキスト最適化する。単一ファイルも複数ファイル群の MECE 横断レビューも扱う"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# refactor context

## When to Use

- 使う: 単一ファイル内のコンテキストを圧縮・整理
- 使う: 複数ファイル群を横断して SSOT / DRY / SRP / MECE / スコープ適合を見る
- 使わない: SKILL 本文の設計、新規 agent / workflow の scaffold

## モードとスコープ

- モード: `自動` / `オート` / `auto` 含む → オート（不可逆・影響大は提案止まり）。それ以外は確認モード
- スコープ: `指定なし` は対象のみ / `ALL` / `Global` (=`%APPDATA%/Code/User/prompts/`) / `ALL + Global`
- 対象外（明示指定なき限り）: `.github/skills/`, `.vscode/settings.json`
- スコープ境界: `Global` 対象は Global User Data 内で完結させる。明示許可なしに現在の workspace / repo へ移動・分割・SSOT 化を提案しない
- 現在 workspace は参照情報としてだけ使う。配置先提案の既定にしない


## 判断ルール

目標: 対象ファイルを AI が判断できる最小情報に圧縮する。人間向け可読性は二次

- 残す: ユーザー固有事実 / ID / パス / 方針、参考 URL・設計根拠、Example（最低 1 つ）、非自明な手順
- 圧縮: 重複定義 / 他セクションとの重複 / 自明な内容 / 人間向け装飾 / AI 判断に委ねていい具体数値 / 冗長な前置き
- 削除: 役割が消えた節 / 他ファイルに統合済みの重複 / 無効化されたルール / 古い example
- 削除禁止: 運用メタコメント（`syncToGlobal` / `author` / `repository` / `license` / `copyright`）

## レビュー観点

- SSOT / DRY / SRP / スコープ適合
- `applyTo` / 常時ロード / 手動呼び出しの整合
- agent / prompt は本文の `#tool:` 参照が frontmatter `tools` と整合しているか（不一致は lint エラー）
- ルーティング（いつ使う / 使わない / どこへ逃がす）が明確か
- Global 対象の逃がし先は Global User Data の prompt / instruction / agent、または personal skill に限る。workspace へ逃がす案は「明示許可が必要」と書く

複数ファイル時のみ追加:

- MECE: 同じ概念の重複定義なし / 想定タスクに空白なし
- 配置適合（always-on / scoped / 手動参照）
- 逃がし先有効性: 対象スコープ内の `applyTo` 付き instruction / 明示呼び出し型 prompt・agent・skill / references のいずれか。**不可**: 別スコープへの移動・参照リンク（明示許可がある場合を除く）
- ファイル提案順序: 削除（役割消失 / 重複） → 既存への統合 → 既存ファイル内の整理 → 分割 → 新規追加。新規ファイルは最後の手段
- Global 対象のファイル提案順序: Global 内で削除 → Global 既存へ統合 → Global 既存内で整理 → Global 内で分割 → Global 新規追加。workspace 化は提案順序に含めない
- ファイル削除は破壊的なのでオートモードでも提案止まり

## 手順

1. 対象ファイルを全件読み、Before→After を提示（行数/見出し数も）
2. 50 行以下は原則「変更不要」。レビュー観点に明確な問題があれば提案
3. 適用は 1 ファイルずつ
4. 適用後にレビュー観点を再確認。複数ファイル時は MECE 改善（重複消失 / 空白未増）も確認
