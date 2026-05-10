---
name: "retro-workspace"
description: "workspace / repository の設計資産へ反映するレトロ。インシデントや会話から知見を抽出し、.github、AGENTS.md、hooks への変更案に落とす"
argument-hint: "エラーログ、diff、会話要約、またはインシデント内容"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Retro Workspace

インシデント・会話から再利用可能な知見を抽出し、workspace / repository の設計資産へ反映するための変更案を作る。

## When to Use

- 使う: バグ解決後 / 再発発生時 / レビューで workspace 設計ギャップが見つかったとき
- 使う: `.github/**`、`AGENTS.md`、repo 固有 instructions / prompts / agents / hooks へ反映すべき運用知見があるとき
- 使う: 試行錯誤の結果、workspace 共有で再利用できる汎用 script / task / helper へ昇格した方がよいと判断できるとき
- 使わない: typo など軽微修正のみ / 環境固有問題のみ
- 使わない: VS Code User Data へ反映すべき内容。代わりに `retro-user` を使う
- 使わない: `~/.copilot` 配下へ反映すべき内容。代わりに `retro-copilot` を使う

## Phase 1: Context Collection

- 入力（1つ以上必須）
   - エラーログ、Git diff/commit、会話履歴、ターミナル履歴
- 既定の反映スコープ
   - workspace / repository 共有資産を優先する
   - User Data や `~/.copilot` へ反映すべき知見はこの prompt では扱わず、Stop Output で handoff を提案する
   - memory 系スコープは反映先にしない
- ターミナル観点
   - Exit Code != 0
   - Ctrl+C（中断）
   - 同コマンド反復
   - 長時間実行
- Gate: 入力なしなら追加要求して停止

## Workflow

```text
Context -> Extract -> Safety & Scope Gate -> Decide Action & Target -> Validate & Output
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
- No Memory Targets Gate
   - `/memories/**`、user memory、session memory、repo memory を反映先にしない
   - memory に残す必要がある依頼は、この prompt では実行せず別タスクとして明示確認する
- Scope Gate
   - workspace / repository 共有資産に置くべき内容か確認する
   - VS Code User Data や `~/.copilot` に置くべき内容なら、この prompt では反映せず handoff を提案する
- Gate（全必須）
   - 永続化する知見は再利用可能なルールに抽象化されている
   - 証拠は必要最小限で、機微情報を含まない
   - workspace 共有資産に置くべき内容か確認済み
   - No Memory Targets Gate を通過済み
- Gate 失敗時は反映せず、Stop Output で理由と安全な代替案を出す

## Refactor Context Rules

- SSOT を守る。重複定義は統合する
- 新規ファイル作成より既存ファイルへの統合を優先する
- 既存ファイルに 1 セクション追加や 1 ルール追記で済むなら、新規ファイルを作らない
- 単一ルール追加や導線追加は catch-all な既存ファイルを優先し、新規ファイルは最後の手段にする
- 新規ファイルは、既存ファイルの役割に収まらず `Target Rationale` で必要性を説明できる場合だけ許可する
- 汎用 script / task / helper の新規追加は workspace でのみ許可する。以下を満たす場合だけ候補にしてよい
   - 一時対応ではなく、同種の作業を複数回再利用できる
   - 手作業説明より script 化した方が誤りが減る
   - 依頼スコープ内で有用性を説明できる
   - 保存先・命名・実行方法を workspace 内で自然に定義できる
   - ユーザー承認前は提案止まりにする
- 50 行以下の小さいファイルは、明確な価値がない限り変更不要または最小差分とする
- 冗長説明は圧縮するが、根拠 URL・非自明な手順・運用メタコメントは消さない
- `Target Rationale` では「なぜ新規作成でなく既存統合か」を必ず説明する

## Phase 3: Decide Action & Target

この Phase では反映先と変更案を決めるだけにする。ユーザー承認前にファイル作成・編集を行わない。

- 優先度: Impact x Recurrence（P1/P2/P3）
- 反映先
   - 共通原則 / 導線 → `AGENTS.md`
   - workspace 共通ルール → `.github/copilot-instructions.md`
   - workflow / ドメイン別ルール → `.github/instructions/**/*.instructions.md`
   - prompt パターン → `.github/prompts/*.prompt.md`
   - agent 固有 → `.github/agents/*.agent.md`
   - hooks → `.github/hooks/**/*.json`
   - 汎用 script / task / helper → workspace 内の自然な配置先（例: `scripts/`, `tools/`, `.vscode/tasks.json`）
   - 補足ドキュメント → workspace docs（既存構成に合う場合のみ）
- **反映禁止**
   - VS Code User Data の `*.prompt.md` / `*.instructions.md` / `*.agent.md`
   - `~/.copilot` 配下の instructions / skills / agents / hooks / mcp 設定
   - `/memories/**`、user memory、session memory、repo memory
   - `.github/skills/**/*.md`
   - Resource Ninja / preset index 関連ファイル
- 反映先ファイルが存在しない場合:
   - 新規作成を変更案として提示する
   - ディレクトリも不在なら、作成予定のパスと理由を示す
   - ユーザー承認後に Phase 4 の重複/矛盾チェックへ進む

### Decision Rules

- まず既存 workspace 資産へ統合できないかを見る
- `.github/copilot-instructions.md` は workspace 共通原則と導線を優先し、業務ドメイン固有の詳細ルールは `.github/instructions/**/*.instructions.md` を優先する
- 試行錯誤のログや一時コマンド列を残すより、再利用価値のある汎用 script / task / helper に昇格した方がよい場合は、その案を出してよい
- ただし、1 回限りの操作や環境依存の強い手順は script 化せず、既存ファイルへの統合または docs 化を優先する
- 新規作成は既存の役割に収まらない場合だけ
- User Data へ反映すべき内容は `retro-user` に handoff する
- `~/.copilot` へ反映すべき内容は `retro-copilot` に handoff する
- memory 系スコープは反映先にしない
- 反映禁止先には入れない
- 最小差分で反映する

## Phase 4: Validate & Output

ユーザーが変更案を承認した場合のみ、対象ファイルを作成・編集する。承認前の出力は提案に留める。

- Gate（全必須）
   - Workspace scope confirmed
   - 重複ルールなし
   - 既存設計と矛盾なし
   - 各変更は最小差分
   - Safety & Scope Gate 通過済み
   - No memory target selected
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

Stop: 知見なし / ユーザー拒否 / Gate 失敗 / handoff-required

## Success Output Format

```markdown
# Retro: [Title]

## Learnings

1. **Learning**: [What was learned]
   - Evidence: [What happened]
   - Impact: [Why it matters]

## Changes

- [What to change]

## Target Rationale

- [Why this workspace target was chosen]
- [Why existing files were preferred over new files]
- [Why User Data / copilot / memory targets were not selected]

## Review Checkpoint

- [ ] User approved proposed changes
- [ ] Workspace scope confirmed
- [ ] No duplicate rules verified
- [ ] Target files are writable
- [ ] Safety & Scope Gate passed
- [ ] No memory target selected
```

## Stop Output Format

```markdown
# Retro: [Title]

## Status

- State: [no-actionable-learning / rejected / blocked / awaiting-approval / handoff-required]
- Reason: [Why the workflow stopped]

## Proposed Changes

- [Change proposal, if any]

## Target Rationale

- [Target proposal and why]
- [Why User Data / copilot / memory targets were not selected]

## Safety Notes

- [Secrets/privacy/scope notes]

## Review Checkpoint

- [ ] User approved proposed changes
- [ ] Workspace scope confirmed
- [ ] No duplicate rules verified
- [ ] Target files are writable
- [ ] Safety & Scope Gate passed
- [ ] No memory target selected
```
