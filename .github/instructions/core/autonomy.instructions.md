---
description: "自律的タスク実行の行動指針（問題解決、代替手段）"
applyTo: "**"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-05-24 -->

# Autonomy and Task Execution Instructions

自律的にタスクを進めるための最小ルール。

## Work End-to-End

- 調査、実装、検証、報告まで一続きで進める。
- ユーザーが「やりきる」「最後まで」「end-to-end」を求めているときは、途中説明や部分進捗で締めず、完了または明確な stop-state まで進める。
- エラーが出たら原因を読み、代替案を試してから相談する。
- 長い multi-step workflow は、着手前に残フェーズと stop-state を見積もり、中途半端な target binding や partial artifact だけを増やさない。
- テストや検証手段がある場合は、実行してから完了扱いにする。
- 途中で `failed` / `blocked` / provisional PASS を見ても、その同じターンで blocker 解消や current artifact 修復により再開可能と分かった場合は、そこで止まらず final gate・state 同期・cleanup まで続ける。
- 途中で止めず、未解決の前提や未実行の検証は明示する。

## Decide Locally When Safe

- 変数名、関数構造、軽微なリファクタ、既存パターンに沿う修正は自分で判断する。
- 質問前にコードベース、既存パターン、エラー内容を調べる。
- 最初の方法が失敗したら、別手段を試す。
- 一括置換や機械的編集は対象を絞り、実行後に旧文字列の残存確認と差分確認を行う。

## Ask Before High-Impact Choices

- 複数案のトレードオフが大きい設計判断。
- 要件が合理的に推測できない場合。
- UX / デザインの好みが成果に大きく影響する場合。
- security、認証、データ安全性、公開範囲に関わる判断。
- 大規模変更、削除、履歴改変、外部公開。

## External Triage

- 外部 issue / PR / 問い合わせ先へ進む前に、対象 repo や窓口が現役で書き込み可能かを確認する。archived、read-only、移行済みなら、その場で現行の正規トラッカーへ切り替える。
- 類似 issue の確認では「完全一致検索が 0 件」だけで未報告と断定しない。近縁症状を 2〜3 件見て、同一事象か別事象かを切り分けてから起票する。

## Done Criteria

- 要求範囲が満たされている。
- 変更がエラーなく動くことを確認している。
- 関係するテストや lint を実行した、または実行できない理由を説明している。
- 残リスクや次の作業があれば短く報告している。
- 途中停止が必要な場合も、再開に必要な state・artifact・cleanup を残し、次に何を実行すれば再開できるかを確定してから止まる。
- 一時ファイル（スクリプト / 監査 JSON / diff 中間ファイル / task 等）は完了前に削除する。
- 再利用可能な資産（汎用スクリプト / テンプレート / チェックリスト等）は適切な永続先（`scripts/`、`.github/` 等）に保存し、最終報告で保存先と用途を明記する。
- 証跡として一時ファイルを残す場合は理由と保存先を報告する。
- サブエージェントや生成器が「手順」だけを返した場合は未完了扱いにし、成果物の実在、gate 出力、state 更新を確認してから完了宣言する。
