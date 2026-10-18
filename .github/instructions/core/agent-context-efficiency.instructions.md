---
description: "エージェント作業全般の context 効率ルール。検索優先、限定読み、最小実行、反復停止、委譲粒度、報告圧縮を扱う"
applyTo: "**"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-10-16 -->

# Agent Context Efficiency

正しい結果を、必要最小の context で出す。

## Gather

- まず検索、一覧、要約で位置を絞り、必要な範囲だけ読む。
- 小さい設定、schema、短い manifest 以外は、全読みを既定にしない。
- 既に読んだ内容は、変更や検証理由がない限り再読しない。

## Act

- 依頼された成果に必要な最小範囲だけ触る。ついでの整理、リネーム、広いリファクタ、不要な生成物を増やさない。
- repo memory には run をまたいで再利用する知見だけを書く。run 固有の記録はその run の report に書く。
- 決定論的な抽出、集計、置換、検証は script や tool に寄せる。**手計算で平均・件数・比率などを出さない**。スクリプトで sum/count 計算し、ソース (Forms / DB / CSV) の集計値と一致することを確認してから成果物へ転記する。
- prompt / instruction / skill / agent を書くときは、人間に読みやすい装飾より AI が判断できる最小情報を優先する。判断ルール / トリガー / 制約 / Example 1 つで足りる。冗長な前置き、同じ概念の言い換え、重複した観点リストを増やさない。

## Tools

- 狭い確認は、対象・列・件数・範囲を絞った短い command / tool call を直接実行し、出力は取得元で filter / limit / summary する。`web_fetch` はスライド共有・イベントページなどで全文級（数十 KB）を返すことがあるため、数個の事実だけ要るときは `Invoke-WebRequest -OutFile` + 正規表現で該当行だけ抽出する。
- terminal で上書きした直後のファイルを `view` が古い内容で返すことがある。生成直後の結果は terminal の `Get-Content` と更新時刻で確認する。
- raw output は後の監査・再読に必要な場合だけ file に保存する。
- バイナリや大容量ファイルを in-band 経路（tool 戻り値、stdout、CDP の base64 応答）で運ばない。ブラウザのダウンロード機能、`-OutFile`、`--output` のように**転送元が直接 file へ書く**経路を使う。
- セッション中に編集ツール / MCP / 取得ツールが無効化される場合がある。同じ tool + input は1回だけ再試行し、2回連続失敗なら別ルートへ切り替える（例: `create` 不可 → terminal 経由でファイル生成、Playwright MCP 不可 → Python + CDP、`read_powershell` 不可 → ログをファイル出力して `view`）。

## Loop

- 入力や操作方式を変えても同じ永続 state が2回続いたら、fallback ladder 全体を停止する。最終 state・試行済み経路・再開条件を残し、3つ目の迂回策を探さない。
- 反復が増える作業は、手順を固定するか小さな script に切り出す。
- 非自明な作業は、実際の利用経路と応答 schema に基づき合格条件を先に決める。設定値・自己申告・別経路の成功だけで完了とせず、存在未確認の項目や未実行の任意 probe を必須判定に使わない。必要な根拠が未取得なら未確認とする。

## Delegate

- 広い検索、長いログ、複数ページ調査、または返却が概ね100行を超えそうな read-only 作業は、観点ごとの isolated subagent に委譲する。
- context isolation は会話履歴の分離であり、tool / file / network 権限の security boundary とみなさない。
- read-only agent の書き込み監査で text artifact を fingerprint する場合は、保存・formatter 完了後に raw hash と改行正規化 hash を記録し、正規化 hash も変わる説明できない変更だけを汚染とする。
- read-only の探索専用 agent は MCP と `tool_search_tool` を持たないことがある。外部仕様の確認を含むレーンには使わない。`web_fetch` だけ持つ agent は MCP 不在でもエラーにならず直 fetch へ静かに劣化する。
- 子には subgoal、必要な入力、制約、判定基準だけを渡し、親への返却は decision / key evidence / next action と、raw を保存した場合の相対 path に限定する。
- 別チャット / 別エージェントへローカル成果物を引き継ぐときは受け手の file 読取能力を確認し、読めれば実在確認済みの絶対 path を、読めなければユーザーが添付すべきファイルを示す。自分で添付できないなら添付済みと言わない。再利用・公開する資産には絶対 path を残さない。
- review / critic へ委譲するときは、成果物だけでなく**判断根拠の原本**（元データのテキスト化、ダンプ、元仕様）も artifact として渡す。read-only agent は terminal を持たないので、暗号化ファイルや COM / 外部コマンド経由でしか読めない対象は先にテキスト化しておく。
- 引用一致、件数、存在確認のように決定論的に判定できる項目は script で verify し、subagent には意味論と設計の妥当性を任せる。
- `task` は model を省略すると親と同じモデルを継承する場合がある。critic は別ファミリを明示指定する。利用可能なモデル名は `%APPDATA%\Code\logs\<日時>\agenthost.log` の `Found N models:` 行で確認する。Agent Host の `task` は、存在しないモデル名を指定してもエラーにならず通る場合があるため、probe で一覧を得ようとしない（2026-10-18 実測）。
- 簡単な検索・一覧化・要約を subagent に委譲するときは、ユーザーまたは workflow に model の明示指定がない限り、利用可能な低コストモデルを明示指定し、producer の高性能モデルを継承させない。
- モデルを選ぶ・指定するとき（subagent、`.agent.md` の `model`、scheduler task、instruction への記述）は、名前を記憶や agent の既定で決めず、上記 probe などの一覧から同じファミリ・tier の最新世代を選ぶ。旧世代はユーザー指定か、新世代が使えない場合だけ。instruction / skill の本文はファミリと tier で書き、世代・版を固定しない。既存資産に旧世代の固定を見つけたら更新候補として挙げる（無断で差し替えない）。
- 作業途中で新規に切り出した成果物は未レビュー。元ファイルが gate を通っていても、切り出し先は別途 gate にかける。
- 独立タスクは分け、BLOCKED は原因か条件を変えてから再実行する。
- サブエージェントが `thinking` / `redacted_thinking` の 400 や model not found で落ちた場合は、サブエージェント不可と断定せず、利用可能一覧の exact model name か別モデル経路で 1 回だけ再試行する。
- 表示画像が1リクエストで累計20枚を超えると失敗し作業が止まる（2026-10-16実測）。画像が10枚を超えそうなら、DOM・寸法・hashで判定できる項目は画像を見ず、残りは観点ごとに10枚以内で画像対応モデルのサブエージェントへ渡し、1枚ずつ見て所見をテキストで返させる。メインは要点の数枚だけ直接見る。3-5枚ならメインで並列に直接見てよい。**ファイル書き出し**を伴う audit はサブエージェントに一括委任しない。
- 高性能モデルや広い tool 権限は、設計、難所、最終確認に寄せる。

## Report

- 結論を先に短く返す。成功は成果物と検証結果を中心に、失敗は操作・状態・キーエラー・次の一手を示す。
- context を厚く積んだ session では、長い最終報告をチャットへ直接書かない。報告本体は file へ書き出し、チャットは相対 path と短い要約に留める。