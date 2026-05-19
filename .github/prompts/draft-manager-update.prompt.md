---
name: "draft-manager-update"
description: "上司報告、進捗共有、manager update を簡潔に作る。Use when: 上司に状況を短く分かりやすく伝えたい、Teams やメールで報告文を作りたい"
argument-hint: "報告先・用途・文量（例: 部長向け Teams 5行、メール向け、口頭30秒）"
agent: "ask"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# draft manager update

現在の会話、参照中の作業内容、直近の成果物を使って、上司向けの報告文を作成する。

要件:

- 結論を最初に 1 文で書く
- 技術詳細は必要最小限に圧縮し、成果・影響・次アクションを優先する
- 専門用語はそのまま並べず、必要なら短く言い換える
- 実施済み、確認済み、未確定を混ぜない
- 指定がなければ Teams 向けの短文 4〜7 行で出す
- メール向け指定なら件名案 + 本文、口頭向け指定なら 30 秒で話せる長さに最適化する
- Issue、PR、リンク、ファイル名は、相手に価値があるときだけ最後にまとめて添える
- 過度な誇張や自己評価は避ける
- 日本語で書く

出力形式:

結論:
<1文>

要点:
- <実施内容または成果>
- <影響または確認結果>
- <次アクション or 依頼>

必要な場合のみ追加:
補足: <Issue/PR/リンク/未確定事項>