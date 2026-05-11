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

# retro workspace

インシデント・会話から再利用可能な知見を抽出し、workspace / repository の設計資産への変更案を作る。

## When to Use

- 使う: バグ解決後 / 再発時 / workspace 設計ギャップ発見時
- 使う: セッション中に既存手順より効率的な方法を発見したとき
- 使う: `.github/**`、`AGENTS.md`、repo 固有 instructions / prompts / agents / hooks への反映
- 使う: 汎用 script / task / helper への昇格が妥当なとき
- 使わない: typo のみ / 環境固有問題のみ
- 使わない: User Data や `~/.copilot` 配下（別スコープ向け retro prompt を呼ぶ）

## 入力

エラーログ / Git diff / 会話履歴 / ターミナル履歴のいずれか 1 つ以上。なければ追加要求して停止。

## Safety Gate

- 反映禁止: secret / 認証情報 / 個人情報 / 顧客情報 / ローカル絶対パス / 端末固有値
- memory 系スコープ（`/memories/**` 等）は反映先にしない
- User Data / `~/.copilot` に置くべき内容はこの prompt では扱わず handoff を提案
- Gate 失敗時は理由と安全な代替案を出して停止

## 反映先

| 対象 | パス |
| --- | --- |
| 共通原則 / 導線 | `AGENTS.md` |
| workspace 共通ルール | `.github/copilot-instructions.md` |
| ドメイン別ルール | `.github/instructions/**/*.instructions.md` |
| prompt / agent / hooks | `.github/prompts/` `.github/agents/` `.github/hooks/` |
| 汎用 script | `scripts/` 等（再利用価値があり、承認前は提案止まり） |

**反映禁止**: User Data / `~/.copilot` / `/memories/**` / `.github/skills/**` / Resource Ninja 関連

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
- まず既存 workspace 資産へ統合できないかを見る
- 新規作成は既存の役割に収まらない場合だけ
- 最小差分で反映する
- ユーザー承認前はファイル編集しない（提案に留める）

### 3. 承認 + 反映

- 承認後に対象ファイルを作成・編集
- Gate: workspace scope 確認済み / 重複なし / 既存設計と矛盾なし / Safety Gate 通過済み

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
- [ ] User approved
- [ ] Workspace scope confirmed
- [ ] No duplicate rules
- [ ] Safety Gate passed
```

Stop: 知見なし / ユーザー拒否 / Gate 失敗 / handoff-required
