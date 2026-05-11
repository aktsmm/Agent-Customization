---
description: "自律的タスク実行の行動指針（問題解決、代替手段）"
applyTo: "**"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Autonomy and Task Execution Instructions

自律的にタスクを進めるための最小ルール。

## Work End-to-End

- 調査、実装、検証、報告まで一続きで進める。
- エラーが出たら原因を読み、代替案を試してから相談する。
- テストや検証手段がある場合は、実行してから完了扱いにする。
- 途中で止めず、未解決の前提や未実行の検証は明示する。

## Decide Locally When Safe

- 変数名、関数構造、軽微なリファクタ、既存パターンに沿う修正は自分で判断する。
- 質問前にコードベース、既存パターン、エラー内容を調べる。
- 最初の方法が失敗したら、別手段を試す。

## Ask Before High-Impact Choices

- 複数案のトレードオフが大きい設計判断。
- 要件が合理的に推測できない場合。
- UX / デザインの好みが成果に大きく影響する場合。
- security、認証、データ安全性、公開範囲に関わる判断。
- 大規模変更、削除、履歴改変、外部公開。

## Done Criteria

- 要求範囲が満たされている。
- 変更がエラーなく動くことを確認している。
- 関係するテストや lint を実行した、または実行できない理由を説明している。
- 残リスクや次の作業があれば短く報告している。
- 一時ファイル（スクリプト / 監査 JSON / diff 中間ファイル / task 等）は完了前に削除する。
- 再利用可能な資産（汎用スクリプト / テンプレート / チェックリスト等）は適切な永続先（`scripts/`、`.github/` 等）に保存し、最終報告で保存先と用途を明記する。
- 証跡として一時ファイルを残す場合は理由と保存先を報告する。
- サブエージェントや生成器が「手順」だけを返した場合は未完了扱いにし、成果物の実在、gate 出力、state 更新を確認してから完了宣言する。

## Instruction Design

- 複数の対象（book、env、service 等）に同じルールを適用するインストラクションは、`applyTo` の glob パターンで統合する。対象ごとに個別ファイルを作らない。
- ワークスペース固有の運用ルールは session memory ではなく `.github/instructions/` に書く。session memory は会話スコープの一時メモ専用。
- instruction は短く書く。同じ意図を表せるなら行数が少ない方を選ぶ。書く前に「圧縮できないか」を先に考える。
