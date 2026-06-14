---
name: "retro-user"
description: "VS Code User Data の prompt / instruction / agent に知見を反映するレトロ。Use when: retro user, user prompt cleanup, user instruction fix"
argument-hint: "エラーログ、diff、会話要約、既存 User Data 資産、またはインシデント内容"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# retro user

インシデント・会話から再利用可能な知見を抽出し、VS Code User Data の prompt / instruction / agent へ最小差分で反映する。

## When to Use

- 使う: バグ解決後 / 再発時 / 個人グローバル設定の設計ギャップ発見時
- 使う: セッション中に見つけた効率化や、繰り返し指示の既定化を User Data に昇格したいとき
- 使う: `%APPDATA%/Code/User/prompts/` 配下の `*.prompt.md` / `*.instructions.md` / `*.agent.md` への反映
- 使わない: typo のみ / 環境固有問題のみ / workspace / repository / `~/.copilot`

## 入力

エラーログ / diff / 会話履歴 / ターミナル履歴 / 既存 User Data 資産のいずれか 1 つ以上。なければ追加要求して停止。

## Mode

- 既定は `safe-auto`。User Data scope が明確で、既存資産への小〜中規模更新なら確認なしで反映してよい
- `review-only` / `確認だけ` / `dry-run` / `プレビュー` が明示された場合だけ、変更案の提示で停止する
- scope 曖昧、大規模削除、意味変更、公開・同期範囲の変更、secret / 個人情報 / 環境固有値の扱いに迷う場合だけ確認で停止する

## Scope Gate

- 反映先は `%APPDATA%/Code/User/prompts/` 配下の `*.prompt.md` / `*.instructions.md` / `*.agent.md` に限定する
- secret / 認証情報 / 個人情報 / 顧客情報 / ローカル絶対パス / 端末固有値 / `/memories/**` は反映しない
- workspace / repository / `~/.copilot` に置くべき内容は scope 不一致として停止する
- actionable な知見なし、または gate 失敗時は理由と代替案を示して停止する

## Edit Rules

- 新規ファイルより既存への統合を優先し、`削除 → 統合 / 圧縮 → 分離 → 参照化 → 追加` の順で検討する
- 圧縮は AI が判断できる最小情報を主目的にし、人間向け可読性は二次とする
- 冗長説明は圧縮するが、根拠 URL と非自明手順は残す
- 同じ Learning / Evidence / Impact を言い換えて繰り返さず、1 論点 1 塊でまとめる
- User Data では、別 global file への参照化より、各 file が単体で「扱うこと / 扱わないこと」を判断できる形を優先する
- 小さな境界文の重複は、参照依存を避けるためなら許容する
- always-on な prompt / instruction は役割過多を先に疑い、同一ファイル内の圧縮や責務分離を優先する

## 実行手順

### 1. 知見抽出

- 既定化できる繰り返し指示、手順改善、設計ギャップを優先して拾う
- 1 件ごとに Learning / Evidence / Impact を作る

### 2. 変更案作成

- 優先度: Impact x Recurrence（P1/P2/P3）
- まず既存 User Data 資産へ統合できるかを見る
- 追記前に、既存文の置換で済むか、同じ global ファイル内で圧縮できるかを先に判断する
- always-on file では追加より先に圧縮を検討し、routing / global 原則 / scope 境界だけを残す方向を優先する
- 反映後の file が、他の global file の読み込みを前提にせず単体で成立するか確認する
- safe-auto では最小差分で反映し、review-only と Gate 停止時だけ提案に留める

### 3. 反映 + 必要時承認

- safe-auto で編集する
- 確認が必要な条件に該当する場合だけ、対象・理由・影響を示して承認後に反映する

### 3.5. 肥大化チェック（反映後）

反映後、DRY 違反・冗長表現・重複定義があれば圧縮・削除・分離する。

## Example Report

```markdown
# Retro: [Title]
- Learnings: ...
- Changes: ...
- Target: ...
- Gate: pass / stop reason
```

Stop: 知見なし / ユーザー拒否 / Gate 失敗 / handoff-required / review-only
