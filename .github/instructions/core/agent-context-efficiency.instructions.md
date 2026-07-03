---
description: "エージェント作業全般の context 効率ルール。検索優先、限定読み、最小実行、反復停止、委譲粒度、報告圧縮を扱う"
applyTo: "**"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Agent Context Efficiency

正しい結果を、必要最小の context で出す。context を節約する目的は、速度だけでなく注意を保つこと。

## Gather

- まず検索、一覧、要約で位置を絞り、必要な範囲だけ読む。
- 小さい設定、schema、短い manifest 以外は、全読みを既定にしない。
- 既に読んだ内容は、変更や検証理由がない限り再読しない。

## Act

- 依頼された成果に必要な最小範囲だけ触る。
- ついでの整理、リネーム、広いリファクタ、不要な生成物を増やさない。
- 決定論的な抽出、集計、置換、検証は script や tool に寄せる。**手計算で平均・件数・比率などを出さない**。スクリプトで sum/count 計算し、ソース (Forms / DB / CSV) の集計値と一致することを確認してから成果物へ転記する。
- prompt / instruction / skill / agent を書くときは、人間に読みやすい装飾より AI が判断できる最小情報を優先する。判断ルール / トリガー / 制約 / Example 1 つで足りる。冗長な前置き、同じ概念の言い換え、重複した観点リストを増やさない。

## Tools

- 独立した read-only 調査は並列化する。
- 長い生ログではなく、関連エラー、周辺、終了状態、次アクションを残す。
- shell 構文や出力制御はローカルの terminal rule に従う。
- セッション中に編集ツール / MCP / 取得ツールが無効化される場合がある。同じツールを 2 回試して失敗したら、代替ルートへ切り替える（例: `create_file` 不可 → terminal 経由でファイル生成、Playwright MCP 不可 → Python + CDP、`get_terminal_output` 不可 → ログをファイル出力して `read_file`）。粘らずに別ルートへ移す。

## Loop

- 同じ失敗を2回見たら、同条件で再試行しない。
- 反復が増える作業は、手順を固定するか小さな script に切り出す。
- 非自明な作業は、検証方法を先に決めてから進める。

## Delegate

- サブエージェントには、必要な入力、制約、期待出力だけ渡す。
- 独立タスクは分け、BLOCKED は原因か条件を変えてから再実行する。
- サブエージェントが `thinking` / `redacted_thinking` の 400 や model not found で落ちた場合は、サブエージェント不可と断定せず、利用可能一覧の exact model name か別モデル経路で 1 回だけ再試行する。
- 高性能モデルや広い tool 権限は、設計、難所、最終確認に寄せる。

## Report

- 結論から短く返す。
- 成功は成果物と検証結果を中心にする。
- 失敗は、失敗した操作、状態、キーエラー、次の一手を示す。