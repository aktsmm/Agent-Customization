---
name: "retro-user"
description: "VS Code User Data の設計資産へ反映するレトロ。インシデントや会話から知見を抽出し、User Data prompt / instruction / agent への変更案に落とす"
argument-hint: "エラーログ、diff、会話要約、既存 User Data 資産、またはインシデント内容"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# retro user

インシデント・会話から再利用可能な知見を抽出し、VS Code User Data の個人グローバル prompt / instruction / agent への変更案を作る。

## When to Use

- 使う: バグ解決後 / 再発時 / 個人グローバル設定の設計ギャップ発見時
- 使う: セッション中に既存手順より効率的な方法を発見したとき
- 使う: `%APPDATA%/Code/User/prompts/` 配下の `*.prompt.md` / `*.instructions.md` / `*.agent.md` への反映
- 使わない: typo のみ / 環境固有問題のみ
- 使わない: workspace / repository や `~/.copilot` 配下（別スコープ向け retro prompt を呼ぶ）

## 入力

エラーログ / diff / 会話履歴 / ターミナル履歴 / 既存 User Data 資産のいずれか 1 つ以上。なければ追加要求して停止。

## Safety Gate

- 反映禁止: secret / 認証情報 / 個人情報 / 顧客情報 / ローカル絶対パス / 端末固有値
- memory 系スコープ（`/memories/**` 等）は反映先にしない
- workspace / repository や `~/.copilot` に置くべき内容はこの prompt では扱わず handoff を提案
- Gate 失敗時は理由と安全な代替案を出して停止

## Execution Mode

- 既定モードは `safe-auto`。User Data scope が明確で、Safety Gate を通過し、既存資産への小〜中規模な統合・更新で済む場合は、確認なしで反映まで実行してよい
- `review-only` / `確認だけ` / `dry-run` / `プレビュー` が明示された場合だけ、変更案の提示で停止する
- 次の場合だけユーザー確認で停止する: scope 判断が曖昧、大規模削除、既存 prompt / agent の意味を大きく変える変更、公開・同期範囲に関わる変更、secret / 個人情報 / 環境固有値の扱いに迷う場合
- typo・小さな手順補正・既存ルールの抜け補完・確認フローの簡素化は、safe-auto でそのまま反映する

## 反映先

| 対象 | パス |
| --- | --- |
| prompt | `%APPDATA%/Code/User/prompts/*.prompt.md` |
| instruction | `%APPDATA%/Code/User/prompts/*.instructions.md` |
| agent | `%APPDATA%/Code/User/prompts/*.agent.md` |

**反映禁止**: workspace / `.github/**` / `AGENTS.md` / `~/.copilot` / `/memories/**` / Resource Ninja 関連

### Auto モード時の反映可否

| 種別 | auto での自律反映 | 条件 |
| --- | --- | --- |
| `*.instructions.md` | OK | Safety Gate 通過 |
| `*.agent.md` | OK | 役割や権限を大きく変えない小〜中規模更新 |
| `*.prompt.md` | OK | 既存 prompt の運用改善・確認フロー簡素化・手順補正。大きな意味変更だけ確認 |

## Refactor Rules

- SSOT を守る。重複定義は統合
- 新規ファイルより既存への統合を優先
- 50 行以下の小ファイルは最小差分
- 冗長説明は圧縮するが根拠 URL・非自明手順は消さない

## 実行手順

### 1. 知見抽出

- カテゴリ: 設計原則 / ワークフロー / プロンプト設計 / コンテキスト設計 / エラーパターン / 手順改善（既存 prompt / instruction の効率化・簡素化）
- 1 件ごとに Learning / Evidence / Impact を作成
- actionable な知見がなければ停止

### 2. 変更案作成

- 優先度: Impact x Recurrence（P1/P2/P3）
- まず既存 User Data 資産へ統合できないかを見る
- 新規作成は既存の役割に収まらない場合だけ
- 最小差分で反映する
- safe-auto ではファイル編集まで実行する。review-only 指定時と Gate 停止時だけ提案に留める

### 3. 反映 + 必要時承認

- safe-auto で対象ファイルを作成・編集
- 確認が必要な条件に該当する場合だけ、対象・理由・影響を示してユーザー承認後に反映
- Gate: User Data scope 確認済み / 重複なし / 既存設計と矛盾なし / Safety Gate 通過済み

### 4. 報告

```markdown
# Retro: [Title]

## Learnings
1. **Learning**: ...
   - Evidence: ...
   - Impact: ...

## Changes
- ...

## Target Rationale
- ...

## Review Checkpoint
- [ ] safe-auto executed or user approval obtained when gated
- [ ] User Data scope confirmed
- [ ] No duplicate rules
- [ ] Safety Gate passed
```

Stop: 知見なし / ユーザー拒否 / Gate 失敗 / handoff-required / review-only
