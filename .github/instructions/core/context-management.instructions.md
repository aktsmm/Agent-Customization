---
description: "Customization 資産（instructions / prompts / agents / SKILL / copilot-instructions / AGENTS）を作成・編集するときの量、粒度、自己完結性のルール。always-on は短く、具体例は最小限にする"
applyTo: "**/*.prompt.md,**/*.instructions.md,**/*.agent.md,**/SKILL.md,**/copilot-instructions.md,**/AGENTS.md"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-07-13 -->

# Customization Authoring Instructions

Customization 資産を編集するときの量、粒度、自己完結性のルール。

## Core Rules

- 毎ターン読まれる instruction は短く保ち、context rot と命令競合を避ける。
- 各 file は単体で「扱うこと / 扱わないこと」を判断できる形にする。
- Global User Data の prompt / instruction は、他の global file が読まれる前提にしない。
- 同じ概念は同一責務内で二重定義しない。境界文の小さな重複は、参照依存を避けるためなら許容する。
- always-on と `applyTo` 付き instruction で同じ rule を強く重複定義しない。
- 同じ rule を `copilot-instructions.md` と `AGENTS.md` の両方に書かない。
- 既存節を置換・圧縮できないかを先に検討し、言い換えただけの新節を足さない。
- 明示呼び出し前提の `.prompt.md` 同士は、自己矛盾・更新漏れ・description 競合が無ければ役割近接だけで統合しない。
- 主要 instruction は ~120 行を目安にする。500 行を超えたら強い refactor サイン。
- 「行数が増える = 改善」とみなさない。

## Scope and Primitive

- 詳細手順、長い recipe、persona、ドメイン固有規則は always-on に置かない。
- always-on の入口 file には routing と少数の global guardrails だけ残す。
- `tasks.json` のような registry file を実行履歴や試行錯誤ログの置き場にしない。
- prompt / instruction / skill / agent / hook は最小の primitive を選ぶ。単純な primitive で解けるなら agent 化しない。
- skill / prompt / agent は 1 つの用途カテゴリに寄せる。
- 具体的な判定表・例・手順は always-on ではなく scoped instruction、prompt、agent、skill、または references に逃がす。
- AI と script / hook の切り分けは、判断や曖昧さ解消は AI、再現性や fail fast が重要な純作業は script / hook を優先する。
- skill の本体には自明な手順より、よく踏む Gotchas、参照ファイル、scripts / assets の所在を優先して書く。
- review 用 prompt / checklist / skill は設計レビューの置き場にする。既定の対話挙動を変えたい rule は always-on entry か scoped instruction に置く。

## Writing Rules

- 1 主張 = 1 文にする。
- 命令形・具体的・実行可能に書く。
- ルールには短い理由を添える。
- 構造は distinct headings + bullet points にする。
- whitespace は AI から見えない。改行だけで意味を表そうとしない。
- 失敗事例は「ルール 1 行 + 理由 1 行」に圧縮する。
- 例は原則 1 つにする。判断基準を主、例を補助にする。
- 環境固有値（ID、パス、Tenant、コース名など）を例に埋めない。

## Do Not Write

- 抽象的な品質要求: `be more accurate` / `don't miss any issues`。
- Copilot Code Review で外部 URL の規則を参照させるだけの指示。実行に必要な規則は本文に書き、URL は人間による更新確認にだけ使う。
- 装飾・好みの出力スタイル強制。検証可能な出力形式は除く。
- PR ブロック等の挙動変更要求。
- linter / formatter / 設定で済むルール。
- 「常に X 文字以内で答える」など固定の出力長制約。
- デバッグ途中の仮説を確定事実として残す記述。

## Always-On 特有のルール

毎ターン読まれる以下のファイル群には、特定 workflow の長文手順、persona、長い失敗列挙を **書かない**。

| 対象 | 残すもの | 逃がし先 |
| --- | --- | --- |
| `%APPDATA%/Code/User/prompts/*.instructions.md` | 全会話に効く短い原則 | `applyTo` を絞った instruction、prompt、agent |
| `$HOME/.copilot/copilot-instructions.md` | CLI 全体の最低限ルール | 同上 |
| `.github/copilot-instructions.md` | repo-wide の routing と guardrails | `.github/instructions/**` |
| `AGENTS.md` | agent / workflow の薄い registry と入口 | 各 `.agent.md`、prompt、skill |

判断: 「これは casual chat にも効いてほしいか？」が No なら always-on に書かない。

補足:

- 入口 file は索引や Markdown リンク集にしない。リンク先まで参照経路に乗ると本文が短くても太る
- `copilot-instructions.md` と `AGENTS.md` は入口に徹し、詳細の所在は「別ディレクトリ / README / docs 側」程度に留める
- 挨拶、短い Q&A、番号だけの返答のような軽い入力を、明示的な task context なしに workflow intake へ強制しない

## Prompt Compression Granularity

`*.prompt.md` / `*.agent.md` / `SKILL.md` は手動呼び出し型だが、冗長さは判断精度と保守性を下げる。

- 残す: semantic match 用 metadata、トリガー、判断ルール、スコープ、モード分岐、禁止事項。
- 圧縮する: metadata と重複する前置き、同じ概念の再掲、細かすぎる手順番号、言い換え中心の表。
- 粒度は「2 週間後の自分が見て判断できる」最小限にする。

## Change Order

知見を反映する前に、必ずこの順で検討する。

1. 削除: 古い・陳腐化した節を消せないか。
2. 統合/圧縮: 既存節の置換・圧縮で済まないか。
3. 分離: 責務や対象を切り分ける必要があるか。
4. 参照化: 低頻度の深い detail だけを外へ逃がす必要があるか。
5. 追加: ここで初めて追記を検討する。

## Operational Limits and Guidance

- Copilot Code Review 用の単一 instruction file は、約 1,000 行以下を推奨する。これは hard limit ではなく、超えると応答品質が低下する可能性があるという GitHub Docs の現行ガイダンスである。
- 実用上は数十〜数百行を目安とし、長さより責務の集中、具体性、競合の有無を優先して判断する。
- 競合命令は片方を削除するか、責務を分けて一方を参照用の情報にする。
