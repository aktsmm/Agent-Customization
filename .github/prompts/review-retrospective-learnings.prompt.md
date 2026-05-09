---
description: インシデントや会話から設計知見を抽出・反映
argument-hint: "エラーログ、diff、会話要約、またはインシデント内容"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Retrospective Learnings

インシデント・会話から再利用可能な知見を抽出し、適切な設計資産へ反映する。

## When to Use

- 使う: バグ解決後 / 再発発生時 / レビューで設計ギャップが見つかったとき
- 使わない: typo など軽微修正のみ / 環境固有問題のみ

## Phase 1: Context Collection

- 入力（1つ以上必須）
   - エラーログ、Git diff/commit、会話履歴、ターミナル履歴
- 既定の反映スコープ
   - ワークスペース共有資産を優先する
   - 明示指示がある場合のみ、User Data、個人 memory、セッション限定メモを候補にする
- ターミナル観点
   - Exit Code ≠ 0
   - Ctrl+C（中断）
   - 同コマンド反復
   - 長時間実行
- Gate: 入力なしなら追加要求して停止

## Workflow

```text
Context -> Extract -> Decide Action & Target -> Validate & Output
```

## Phase 2: Extract Learnings

- カテゴリ
   - 設計原則（SRP/SSOT/idempotency）
   - ワークフロー
   - プロンプト設計
   - コンテキスト設計
   - エラーパターン
- 1件ごとに `Learning / Evidence / Impact` を作成
- Gate: actionable な知見がなければ停止

## Phase 2.5: Safety & Scope Gate

- 反映禁止または抽象化が必要な情報
   - secret、認証情報、API キー、接続文字列
   - 個人情報、顧客情報、個人アカウント値
   - ローカル絶対パス、端末固有値、一時ディレクトリ
   - 公開・共有に不向きな会話本文やログ断片
- Gate（全必須）
   - 永続化する知見は再利用可能なルールに抽象化されている
   - 証拠は必要最小限で、機微情報を含まない
   - workspace 共有資産に置くべき内容か確認済み
- Gate 失敗時は反映せず、Stop Output で理由と安全な代替案を出す

## Phase 3: Decide Action & Target

この Phase では反映先と変更案を決めるだけにする。ユーザー承認前にファイル作成・編集を行わない。

- 優先度: Impact × Recurrence（P1/P2/P3）
- 反映先
   - 共通原則 → `AGENTS.md`
   - agent 固有 → `.github/agents/*.agent.md`
   - workflow ルール → `.github/instructions/**/*.instructions.md`
   - prompt パターン → `.github/prompts/*.prompt.md`
   - 明示指示がある場合のみ → User Data prompts/instructions、個人 memory、セッション限定メモ
- `AGENTS.md` が最適な反映先で、まだ存在しない場合:
   - `AGENTS.md` の新規作成を変更案として提示する
   - 既存の `.github/copilot-instructions.md` や `.github/instructions/**/*.instructions.md` と役割が競合しないよう、共通原則と導線だけを最小差分で置く
- **反映禁止**
   - `.github/skills/**/*.md`（SKILL.md 等のスキルファイルは編集しない）
- 反映先ファイルが存在しない場合:
   - 新規作成を変更案として提示する
   - ディレクトリも不在なら、作成予定のパスと理由を示す
   - ユーザー承認後に Phase 4 の重複/矛盾チェックへ進む

### Decision Rules

- まず既存資産へ統合できないかを見る
- `.github/copilot-instructions.md` は workspace 共通原則と導線を優先し、業務ドメイン固有の詳細ルールは `.github/instructions/**/*.instructions.md` を優先する
- 追記候補が特定ドメインの運用ルールで、`copilot-instructions.md` が受け皿化している場合は、新規 instruction への分離を第一候補にする
- catch-all な既存ファイルに追記する場合は、「なぜ専用 instruction ではなくそのファイルなのか」を説明できる場合に限る
- 新規作成は既存の役割に収まらない場合だけ
- User Data や個人 memory は、ユーザーが明示的に個人スコープを指示した場合だけ選ぶ
- 反映禁止先には入れない
- 最小差分で反映する

## Phase 4: Validate & Output

ユーザーが変更案を承認した場合のみ、対象ファイルを作成・編集する。承認前の出力は提案に留める。

- Gate（全必須）
   - 重複ルールなし
   - 既存設計と矛盾なし
   - 各変更は最小差分
   - Safety & Scope Gate 通過済み
- 出力
   - `## Learnings`
   - `## Changes`
   - `## Review Checkpoint`
   - `## Target Rationale`

## Completion Criteria

- 全入力分析済み
- 優先度分類完了
- Gate 通過
- 設計資産へ実反映する場合のみユーザー承認済み

Stop: 知見なし / ユーザー拒否 / Gate 失敗

## Success Output Format

⚠️ **通常完了時はこの形式で 1 回だけ出力する。**

```markdown
# Retro: [Title]

## Learnings

1. **Learning**: [What was learned]
   - Evidence: [What happened]
   - Impact: [Why it matters]

## Changes

- [What to change]

## Target Rationale

- [Why this target was chosen]
- [Why `.github/copilot-instructions.md` was or was not selected]
- [If a new instruction file is proposed, why existing files were insufficient]

## Review Checkpoint

- [ ] User approved proposed changes
- [ ] No duplicate rules verified
- [ ] Target files are writable
- [ ] Safety & Scope Gate passed
```

## Stop Output Format

知見なし / ユーザー拒否 / Gate 失敗 / 承認待ちの場合は、実反映せずこの形式で出力する。

```markdown
# Retro: [Title]

## Status

- State: [no-actionable-learning / rejected / blocked / awaiting-approval]
- Reason: [Why the workflow stopped]

## Proposed Changes

- [Change proposal, if any]

## Target Rationale

- [Target proposal and why]

## Safety Notes

- [Secrets/privacy/scope notes]

## Review Checkpoint

- [ ] User approved proposed changes
- [ ] No duplicate rules verified
- [ ] Target files are writable
- [ ] Safety & Scope Gate passed
```

<!--
References:
- Anthropic Building Effective Agents: https://www.anthropic.com/engineering/building-effective-agents
- Anthropic Context Engineering: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
-->
