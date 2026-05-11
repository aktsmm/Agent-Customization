---
description: "指定スコープの instruction / prompt / agent 定義を単発でコンテキスト最適化する"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# refactor context

ユーザーが指定したスコープに応じて対象をレビューし、コンテキストを最適化する。

## When to Use

- 使う: 単発で対象ファイル / フォルダのコンテキストを圧縮・整理したいとき
- 使う: その場で冗長説明や重複表現を最適化したいとき
- 使わない: 複数資産を横断して SSOT・整合性・構造を判定したいとき → `review-agents-and-instructions` を使う

## モード

- `自動` / `オート` / `auto` を含む: オート（不可逆・影響大は提案止まり）
- それ以外: 確認（提案後に適用対象を確定）

## スコープ

- 指定なし: 指定ファイル/フォルダのみ
- `ALL`: ワークスペース全対象
- `Global`: `%APPDATA%/Code/User/prompts/`
- `ALL + Global`: 両方

対象外（明示指定がない限り）:
- `.github/skills/`
- `.vscode/settings.json`

## 原則

- 判断優先（原則・例外・禁止事項を先に）
- 外部メモリ（URL/根拠/Example）を消さない
- SSOT を守る（重複定義は統合）
- 非自明でない大量コマンド例は削減
- 運用メタコメント（`syncToGlobal` / `author` / `repository` / `license` / `copyright`）は削除禁止

## ルール

### 残す
1. ユーザー固有事実/ID/パス/方針
2. 参考URL・設計根拠
3. Example Output（最低1つ）
4. 非自明な手順・チェック

### 短縮/削除
5. 冗長説明・重複説明を圧縮
6. 自明な内容だけ削除（迷ったら残す）
7. 動作非依存メタ情報は削除可（ただし運用メタコメント5種は除外）

## 手順

1. 対象ファイルを全件読む
2. 最適化案を提示（Before→After）
   - 50行以下は原則「変更不要」
   - 可能なら `行数/見出し数/code block数` も提示
3. 確認モードでは承認後に1ファイルずつ適用
4. オートモードでは1ファイルずつ適用（不可逆・影響大は除外）

## 品質チェック

- 全適用後に矛盾/重複/過剰削除/スコープ逸脱をレビュー
- `runSubagent` が使えれば最大2回、不可なら自己レビュー1回

