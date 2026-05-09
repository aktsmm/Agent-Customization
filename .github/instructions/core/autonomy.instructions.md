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
