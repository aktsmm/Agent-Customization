---
name: "create-session-handoff"
description: "Use when: 現在の会話・作業状態から、別セッションへそのまま渡せる自己完結した依頼文を作る。依頼文の生成のみで、対象作業は実行しない"
argument-hint: "次セッションへ依頼したい作業、終点、除外事項（省略時は会話から推定）"
agent: "agent"
tools: [vscode/askQuestions, execute/runInTerminal, read, vscodeGeneral/usages, search]
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# 別セッション向け依頼文を作成

現在の会話から、次セッションへ貼り付けられる自己完結した依頼文を作る。これは引き継ぎ文の作成であり、対象作業の代行ではない。

## 実行境界と応答フェーズ

- この prompt を実行する現在のセッションでは、実装・変更・テスト・workflow・外部操作を実行しない。許可するのは読み取り、検索、書き込みゼロの状態確認だけ。
- 保存先を明示されない限り、handoff 文をファイル保存しない。
- tool capability は実行許可ではない。terminal を使う場合も副作用ゼロの確認だけにする。
- **第1応答**: `vscode/askQuestions` で、推定した大目的を1問だけ確認して回答を待つ。ユーザー訂正が正本。
- **第2応答**: 回答を反映した handoff 全文を、単一の Markdown fenced block だけで出力する。ブロック外に前置き・補足を書かない。

## 情報の優先順位

`最新のユーザー指示・訂正 > 現在の artifact / state / 検証結果 > 既存 handoff > 古い計画・途中ログ`。

- active selection は参考情報であり、対象確定の根拠にしない。
- 未確認の値は推測せず `<要確認>` または `<未取得>` と書く。
- workspace がなければ会話内の合意を正本にする。workspace があれば検索・読み取りを優先する。
- workspace の事実確認は最新ユーザー指示を上書きしない。
- 未承認の高リスク操作は列挙外も含め Must NOT に入れる。例: publish / push / delete / deploy / 送信 / 購入 / 履歴改変 / 認証・権限変更 / 本番更新 / 共有プロセス停止。

## Provenance

handoff 冒頭に必ず次を置く。

- 大目的: 当初の目的。方針転換があれば現在の大目的も追加（最大2行）。同じなら1行。
- 次セッション名: 元名 + ` Re`。既に `Re` なら `Re2`。元名不明なら Goal から短く作る。
- 推奨モデル: ユーザー指定を優先。未指定なら実在確認済みの表示名だけを使い、設計・高リスクは高性能、定型は軽量を選ぶ。
- セッション系譜、作成日、workspace、主要 artifact の相対 path。

### 系譜の更新

1. 既存 handoff の系譜または旧形式の作成元 ID を引き継ぐ。なければ今回を root にする。
2. 現在の session GUID（`{{VSCODE_TARGET_SESSION_LOG}}` の末尾）を作成元として追加する。
3. `root: <id> → … → <recent> → 作成元: <id>` の形にする。root と root 以外の直近2件だけを残す。
4. 省略が発生した場合だけ `…` を残す。ID は推測せず `<未取得>` を使う。系譜フィールド自体は省略しない。

## 次セッションの開始ゲート

生成する handoff は、原則として次セッションに即時実装を命じない。

- `Goal` は「候補を整理し、ユーザーの選択に従って実行する」とする。
- `Required Work` には候補ごとの目的・前提・期待成果だけを書く。
- 次セッションの第1応答は、Current State の短い要約と A/B 候補を提示する。例: `理解しました。現在は ... です。次は A（...）/ B（...）のどちらにしますか？`
- 次セッションは、明示的な `進めて` / `実装して` / 候補名の選択まで、読み取り確認以外の変更・テスト・workflow 実行をしない。
- **省略条件**: 最新のユーザー指示が「次セッションで特定作業を直ちに実行する」と明示している場合だけ、開始ゲートを省略して Goal を固定する。対象名だけ、候補、TODO、推奨案は省略根拠にしない。

## Grounding と workflow

- 現在状態、完了 / 未完了、検証結果、変更可能範囲、高影響操作の境界を確認する。
- 関連する direct-entry workflow がある場合、handoff はその invocation を正本にする。target を handoff 側で固定する場合と、selector / workflow 自身が決める場合の両方を含む。workflow が所有する phase / lifecycle / Must NOT を転載しない。
- 別セッションが所有中、または所有競合が合理的に疑われる場合、完走観測点、読み取り専用の許可 command / tool、共有 queue・scheduler・single-writer の禁止対象を handoff に明記する。

## Handoff の構成

小規模・低リスクは簡潔構成、複数工程・再開・高リスク・外部操作は詳細構成にする。

| 常に含める | 詳細時に追加する |
| --- | --- |
| Provenance / Goal / Current State / Done / Required Work / Completion Criteria / Must NOT / Final Report / 開始時の問い | 背景・対象読者 / artifact 配置 / 工程別作業 / 根拠・変更履歴 / 安全境界 / rollback |

- コード: 対象 file / schema / tests / compatibility を書く。
- 調査: 質問、対象期間、比較軸、情報源、事実と未確認を分ける。
- 文書: 読者、媒体、保持すべき主張、引用制約を追加する。
- 運用: 対象環境、dry-run、readback、rollback、承認境界を追加する。

## 別モデル review

複雑・高リスク・多段・意味的判断が重要、またはユーザーが要求した場合だけ含める。

- producer が scope と合否を所有する。worker には subgoal・入力・AC・禁止事項・証跡だけ渡す。
- reviewer は producer と別モデル family の read-only reviewer にする。
- 別モデルが利用不能なら `review_blocked` と明記し、同一モデル self-review を独立評価と呼ばない。

## 出力前チェック

- 大目的の確認回答を反映した。
- 系譜フィールドがあり、IDを推測していない。
- 開始ゲートの採用・省略が最新ユーザー指示に一致する。
- 開始ゲートを採用する場合、次セッションの第1応答は状態要約 + 候補提示だけで実行を開始しない。
- 現在状態と未完了を混同していない。
- 単一 fenced block が閉じている。

## 出力

貼り付け可能な handoff 全文だけを、単一の `markdown` fenced block で出力する。本文に code block が必要なら外側を4連以上の backtick にする。
