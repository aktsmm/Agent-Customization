---
name: "retro-user"
description: "VS Code User Data の prompt / instruction / agent に知見を反映するレトロ。Use when: retro user, user prompt cleanup, user instruction fix。workspace 資産は retro-workspace、private skill repo は retro-private-skills を使う"
argument-hint: "エラーログ、diff、会話要約、既存 User Data 資産、またはインシデント内容"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
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

- scope 不一致 / handoff-required による停止は当該知見だけに適用し、安全に独立処理できる対象内の知見は続行する。実行全体の安全性が未確定な場合は停止する。
- 別の Retro / workflow が適切な知見は、推奨先・理由・引き継ぐ知見を示す。推奨先の実在と担当 scope を確認し、未確認なら `確認待ち` として不足情報を示す。許可 scope 外へ自動で切り替えて編集しない。
- 反映先は `%APPDATA%/Code/User/prompts/` 配下の `*.prompt.md` / `*.instructions.md` / `*.agent.md` に限定する
- secret / 認証情報 / 個人情報 / 顧客情報 / ローカル絶対パス / 端末固有値 / `/memories/**` は反映しない
- workspace / repository / `~/.copilot` に置くべき内容は scope 不一致として停止する。workspace へ handoff する場合は、アクティブ VS Code workspace を既定の反映先とし、ユーザー指定なしに外部の新規プロジェクトフォルダを提案しない
- 追加内容は Self-Contained を保つ：取り込んだ file が他 file への hard reference なしで成立するようにする。ツール制約 (例: Copilot CLI は prompt 不可、SKILL primitive のみ) を踏まえた primitive 選択をした上で、User Data 以外への反映は handoff する
- actionable な知見なし、または gate 失敗時は理由と代替案を示して停止する

## Edit Rules

- 既存の意味で充足する知見は `既存で充足` とし、同じ知見の再実行でも変更しない。差分が必要なら新規作成・追記より削除・置換・統合・圧縮を優先し、不足時だけ分離・追加を検討する。
- 圧縮は AI が判断できる最小情報を主目的にし、人間向け可読性は二次とする
- 冗長説明は圧縮するが、根拠 URL と非自明手順は残す
- 同じ Learning / Evidence / Impact を言い換えて繰り返さず、1 論点 1 塊でまとめる
- User Data では、別 global file への参照化より、各 file が単体で「扱うこと / 扱わないこと」を判断できる形を優先する
- 小さな境界文の重複は、参照依存を避けるためなら許容する
- always-on な prompt / instruction は役割過多を先に疑い、同一ファイル内の圧縮や責務分離を優先する

## 実行手順

### 0. Pre-Flight Inventory

知見抽出前に、サブエージェントで User Data の候補資産と既存規則を調べ、always-on への不要な追加や重複を防ぐ。

### 1. 知見抽出

- 既定化できる繰り返し指示、手順改善、設計ギャップを優先して拾う
- 全知見を論点別に列挙し、それぞれ Learning / Evidence / Impact と最適な反映先を決める。

### 2. 変更案作成

- 優先度: Impact x Recurrence（P1/P2/P3）
- まず既存 User Data 資産へ統合できるかを見る
- 追記前に、既存文の置換で済むか、同じ global ファイル内で圧縮できるかを先に判断する
- always-on file では追加より先に圧縮を検討し、routing / global 原則 / scope 境界だけを残す方向を優先する
- 反映後の file が、他の global file の読み込みを前提にせず単体で成立するか確認する
- 明示依頼なしでも、採用知見は許可 scope 内の不足する全反映先へ最小差分で反映する。独立した責務を持つ反映先には自己完結した規則を置き、長い重複は作らない。
- safe-auto では最小差分で反映し、review-only と Gate 停止時だけ提案に留める

### 3. 反映 + 必要時承認

- safe-auto で編集する
- 確認が必要な条件に該当する場合だけ、対象・理由・影響を示して承認後に反映する

### 3.5. 肥大化チェック（反映後）

- 変更範囲の重複・冗長さを削除・置換・統合する。変更前後の本文文字数を同じ改行条件で測定し、純増時だけ差分と置換では足りない理由をチャットで報告する。必要な新知識は追加できるが、量を減らすために非自明な手順・判断基準は削らず、実行のたびに履歴ファイルを増やさない。

### 4. 検証

- 抽出した全知見を `反映済み / 既存で充足 / 見送り / handoff / 確認待ち / 承認待ち / 提案のみ` に分類し、反映先または理由と照合して未処理を残さない。対象外の知見は推奨先の確認済みなら `handoff`、未確認なら `確認待ち` とし、対象外という理由だけで `見送り` にしない。review-only の変更案は `提案のみ` とし、反映済みと報告しない。
- 文法、診断、diff に加え、反映した運用手順の代表経路を実行する。フォールバック追加なら通常経路ではなくフォールバック自体を試す。
- インシデントが文字コード、応答サイズ、認証、リダイレクトなどの境界条件を含む場合は、その条件を再現する入力を少なくとも 1 件含める。
- 実経路を試せない場合は未検証と明記し、静的検証だけで完了扱いにしない。

## Example Report

```markdown
# Retro: [Title]
- Learnings: 各知見の状態 / 反映先 / 未反映理由
- Changes: ...
- Target: ...
- Handoff: 推奨 Retro / workflow・理由・引き継ぐ知見（なければ none）
- Gate: pass / stop reason
```

Stop: 知見なし / ユーザー拒否 / Gate 失敗 / review-only。handoff-required は当該知見のみ引き継ぐ。
