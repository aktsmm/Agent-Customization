---
description: "Customization 資産（instructions / prompts / agents / SKILL / copilot-instructions / AGENTS）を作成・編集するときの中身の量と粒度の SSOT。always-on は特に短く、足せばいいわけではない、具体例は最小限、理由は書く"
applyTo: "**/*.prompt.md,**/*.instructions.md,**/*.agent.md,**/SKILL.md,**/copilot-instructions.md,**/AGENTS.md"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Context Management Instructions

Customization 資産（instructions / prompts / agents / SKILL / copilot-instructions / AGENTS）を編集するときの「何を、どれだけ書くか」の SSOT。

## なぜ context を絞るか

- context は有限。毎ターン読まれる instruction はトークン税として乗り続ける
- トークンが増えると recall が下がる（context rot）
- AI は non-deterministic。命令を毎回完璧には守らない前提で書く
- 競合・冗長・抽象な命令は精度を下げる
- 公式も短く・自足的・競合させない方針を明言している

## 5 原則

### 1. SSOT
- 同じ概念は 1 ファイルに集約。他では参照リンクだけにする
- always-on と `applyTo` 付き instruction で重複定義しない
- 同じ rule を `copilot-instructions.md` と `AGENTS.md` の両方に書かない

### 2. DRY
- 既存節を置換・圧縮できないかを先に検討してから追記する
- 言い換えただけの新節を足さない
- 失敗事例は「ルール 1 行 + 理由 1 行」に圧縮、長文列挙はしない

### 3. 短く保つ
- 冗長な前置き、「重要！」連打、自明な説明を削る
- 主要 instruction は ~120 行を目安、500 行を超えたら強い refactor サイン
- 「行数が増える = 改善」とみなさない
- whitespace は AI から見えない。区切りは見た目の問題でしかない

### 4. 分離する
- 詳細手順、長い recipe、persona、ドメイン固有規則は always-on に置かない
- always-on の入口ファイルには routing と少数の global guardrails だけ残す
- `tasks.json` のような registry file を実行履歴や試行錯誤ログの置き場にしない
- prompt / instruction / skill / agent / hook は最小の primitive を選び、より単純な primitive で解けるなら agent 化しない
- それ以外は `applyTo` を絞った instruction、`.prompt.md`、`.agent.md`、references に逃がす
- AI と script / hook の使い分けは汎用原則だけを always-on に置き、具体的な判定表・例・手順は scoped instruction や review asset を正本にする
- 判断や曖昧さ解消は AI、同じ入力なら同じ結果が望ましい純作業は script / hook に寄せる
- 単発でも再現性、fail fast、証跡が重要なら script / hook を優先する
- review 用 prompt / checklist / skill は設計レビューの置き場であり、既定の対話挙動を変えたい rule は always-on entry か scoped instruction に置く
- ただし Global User Data の prompt / instruction は、他の global prompt / instruction を前提にしない
- always-on file に Markdown リンク付きの索引を作らない。リンク先まで参照経路に乗ると、本文が短くても入口としては太る
- 入口 file で詳細の所在を示すときは、Markdown リンク列挙より「詳細は別ディレクトリ / README / docs 側」の一文で済まないかを先に検討する

### 5. 反復・テスト前提
- 一発で完成させず、小さく始めて反復で磨く
- 設計は、会話から抽出 → primitive と scope 決定 → 不明点だけ確認 → escalation と pattern 判定 → 拡張前レビュー → 実装と反復、の順で小さく進める
- 効いていないルールは消す、効いているルールは残す
- 新ルールは 1 つずつ足して、追加前後で挙動差を見る
- デバッグ途中の仮説を設計資産へ確定事実として反映しない
- prompt / instruction / agent への反映は、独立検証で再現性を確認してから行う

## 書き方の規範

- 1 主張 = 1 文（short, self-contained statements）
- 命令形・具体的・実行可能に書く
- ルールには **理由** を添える（例: deprecation、security、performance、bundle size）
- 構造は distinct headings + bullet points
- linter / formatter が enforce するルールは書かない
- whitespace は AI から見えない。改行で区切っても意味は変わらない

## 具体例の扱い

- 例は **原則 1 つ**。多くするほど「その例にしか当てはまらない」と誤読され、汎用性が落ちる
- **判断基準（rule）が主、例は補助**
- 環境固有値（ID、パス、Tenant、コース名など）を例に埋めない
- 1 例で意図が伝わらないなら、例を増やすより rule の書き方を直す
- 「理由を書く」と「例は最小限」は両立する。理由は短い文、例は最大 1 ブロック

## 書かないもの

公式が「効かない」「無視される」と明示している型。

- 抽象的な品質要求: `be more accurate` / `don't miss any issues`
- 外部 URL を参照させる指示（取得されない、内容を直接書く）
- 出力スタイル強制（emoji、bold、コメント書式）
- PR ブロック等の挙動変更要求
- linter / formatter / formatter 設定で済むルール
- 「常に X 文字以内で答える」など固定の出力長制約

## Always-On 特有のルール

毎ターン読まれる以下のファイル群には、特定 workflow の長文手順、persona、長い失敗列挙を **書かない**。

| 対象 | 残すもの | 逃がし先 |
| --- | --- | --- |
| `%APPDATA%/Code/User/prompts/*.instructions.md` | 全会話に効く短い原則 | `applyTo` を絞った instruction、prompt、agent |
| `$HOME/.copilot/copilot-instructions.md` | CLI 全体の最低限ルール | 同上 |
| `.github/copilot-instructions.md` | repo-wide の routing と guardrails | `.github/instructions/**` |
| `AGENTS.md` | agent / workflow の registry と入口 | 各 `.agent.md`、prompt、skill |

判断: 「これは casual chat にも効いてほしいか？」が No なら always-on に書かない。

補足:

- 「入口に索引を置く」は原則として避ける。always-on file の索引は、そのまま参照リンク集になりやすい
- `copilot-instructions.md` と `AGENTS.md` は、リンクを起点に深い detail を読ませる場ではなく、入口の役割に徹する
- 挨拶、短い Q&A、番号だけの返答のような軽い入力を、明示的な task context なしに workflow intake へ強制しない

## 追加前のチェック

知見を反映する前に、必ずこの順で検討する。

1. 削除: 古い・陳腐化した節を消せないか
2. 統合/圧縮: 既存節の置換・圧縮で済まないか
3. 分離: 責務や対象を切り分ける必要があるか
4. 参照化: 低頻度の深い detail だけを外へ逃がす必要があるか
5. 追加: ここで初めて追記を検討する

順番を守るだけで append-only 化をかなり防げる。

## 不安定挙動の診断順

casual chat や通常応答が不安定になったら、まず always-on の入口ファイルを疑う。

1. `.github/copilot-instructions.md` の過積載
2. 入口ファイルと `.github/instructions/**` の重複
3. 入口ファイル内の Markdown 参照リンクによる実質的な肥大化
4. `AGENTS.md` と `.agent.md` の役割不整合

入口ファイルを rename / disable した瞬間に casual chat が正常化したら、それは「壊れた」のではなく **over-scoped 確定** のサイン。

## Hard Limits

- Copilot code review は instruction 先頭 **4,000 文字** しか読まない（Chat / cloud agent は対象外）
- 1 ファイル上限の目安は **~1,000 行**、実用は数十〜数百行
- 優先度: Personal > Repository > Organization。同名概念が複数階層にあると衝突する
- 競合命令は片方を消すか参照に置換する
