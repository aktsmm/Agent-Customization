---
name: "retro-workspace"
description: "workspace / repository の設計資産や automation 資産へ知見を反映するレトロ。Use when: retro workspace, workspace prompt cleanup, repo automation fix。User Data は retro-user、`~/.copilot` は retro-copilot、private skill repo は retro-private-skills を使う"
argument-hint: "エラーログ、diff、会話要約、またはインシデント内容"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# retro workspace

インシデント・会話から再利用可能な知見を抽出し、workspace / repository の設計資産や automation 資産へ最小差分で反映する。

## When to Use

- 使う: バグ解決後 / 再発時 / workspace 設計ギャップ発見時
- 使う: 既存手順より安全・再現可能・高速な script / task / helper へ昇格すべき改善を見つけたとき
- 使う: `.github/**`、`AGENTS.md`、repo 固有 instructions / prompts / agents / hooks、scripts、tasks への反映
- 使わない: typo のみ / 環境固有問題のみ / User Data / `~/.copilot`

## 入力

エラーログ / Git diff / 会話履歴 / ターミナル履歴のいずれか 1 つ以上。なければ追加要求して停止。

## Workspace 検出（反映先決定）

知見抽出の前に反映先を決める。この判定はこの prompt 内で完結させ、他の skill / prompt に委譲しない。

1. VS Code Chat でアクティブ workspace folder が提供されている場合: repo marker の有無を問わず、その folder を反映先にする。CWD や外部の新規プロジェクト候補で上書きしない。必要な `.github/` や `AGENTS.md` はその workspace 内に作る
2. アクティブ workspace がない場合: CWD かその親に `.git` / `.github/` / `AGENTS.md` のいずれかがあれば、その repo ルートを反映先にする
3. workspace なし: 自動でファイルを作らず、ユーザーに確認する
   - 選択肢を提示: (a) この知見を残すプロジェクトフォルダを新規作成する / (b) 反映せず handoff（知見だけ提示） / (c) 既存の別フォルダを指定する
   - (a) を選んだ場合のみ、最小のプロジェクトフォルダ（kebab-case slug の `README.md` + `.github/` 雛形）を作成し、そこを反映先にする。作成場所は確認する
   - 確認なしに勝手にフォルダを作らない

## Mode

- 既定は `safe-auto`。workspace scope が明確で、既存資産への小〜中規模更新で済む場合は確認なしで反映してよい
- `review-only` / `確認だけ` / `dry-run` / `プレビュー` が明示された場合だけ、変更案の提示で停止する
- Git 管理下の workspace なら、safe-auto で修正したあと、検証後に skill / scope 単位で local commit を作る。git 操作前は `Set-Location` で cwd を明示し、誤った repo へ commit しない。Git 管理外のフォルダではファイル反映だけで完了とする
- remote が private/internal で、`origin/<branch>..HEAD` が今回の変更だけなら、明示指示なしでも `git push` まで行う。ahead の件数は条件にしない。commit を滞留させると、次に使う PC が古い状態から始まる。関係ない commit や別セッションの dirty が混ざるときは停止して確認する
- scope 曖昧、大規模削除、公開・同期範囲変更、高リスクな実行コード / hook 変更、workflow の意味変更、secret / 個人情報 / 環境固有値の扱いに迷う場合だけ確認で停止する

## Scope Gate

- scope 不一致 / handoff-required による停止は当該知見だけに適用し、安全に独立処理できる対象内の知見は続行する。実行全体の安全性が未確定な場合は停止する。
- 別の Retro / workflow が適切な知見は、推奨先・理由・引き継ぐ知見を示す。推奨先の実在と担当 scope を確認し、未確認なら `確認待ち` として不足情報を示す。許可 scope 外へ自動で切り替えて編集しない。
- 反映先は `AGENTS.md`、`.github/**`、repo 固有 scripts / tasks / helpers に限定する
- secret / 認証情報 / 個人情報 / 顧客情報 / ローカル絶対パス / 端末固有値 / `/memories/**` は反映しない
- User Data / `~/.copilot` は scope 不一致として停止する
- `.github/skills/**` は直接編集せず、SKILL 向きなら提案して停止する
- 反映内容は Self-Contained を保つ：repo 資産が他 file への hard reference に依存せず単体で成立するようにする。大きな文脈を加える場合は、取り外せない SSOT の位置を推奨する

## Edit Rules

- 既存の意味で充足する知見は `既存で充足` とし、同じ知見の再実行でも変更しない。差分が必要なら新規作成・追記より削除・置換・統合・圧縮を優先し、不足時だけ分離・追加を検討する。
- 圧縮は AI が判断できる最小情報を主目的にし、人間向け可読性は二次とする
- 冗長説明は圧縮するが、根拠 URL と非自明手順は残す
- 同じ Learning / Evidence / Impact を言い換えて繰り返さず、1 論点 1 塊でまとめる
- `AGENTS.md` と `.github/copilot-instructions.md` のような入口ファイルは役割過多を先に疑う
- script / task 化は、再利用価値・検証可能性・影響範囲の狭さが揃う場合を優先する

## 実行手順

### 0. Pre-Flight Inventory

知見抽出前に、サブエージェントで反映先候補・scope gate・既存規則を調べ、不要な分散や重複を防ぐ。

### 1. 知見抽出

- 設計原則、workflow、context、automation 改善、繰り返し指示の既定化を優先して拾う
- 全知見を論点別に列挙し、それぞれ Learning / Evidence / Impact と最適な反映先を決める。

### 2. 変更案作成

- 優先度: Impact x Recurrence（P1/P2/P3）
- まず既存 workspace 資産へ統合できるかを確認する
- script / task 化が適切なら既存 runner や script directory を優先する
- entry file では追加より先に圧縮を検討し、`AGENTS.md` と `.github/copilot-instructions.md` の役割差分を崩さない
- 明示依頼なしでも、採用知見は許可 scope 内の不足する全反映先へ最小差分で反映する。独立した責務を持つ反映先には自己完結した規則を置き、長い重複は作らない。
- safe-auto では最小差分で反映し、review-only と Gate 停止時だけ提案に留める

### 3. 反映 + 必要時承認

- safe-auto で編集する
- 確認が必要な条件に該当する場合だけ、対象・理由・影響を示して承認後に反映する

### 3.5. 肥大化チェック（反映後）

- 変更範囲の重複・冗長さを削除・置換・統合する。変更前後の本文文字数を同じ改行条件で測定し、純増時だけ差分と置換では足りない理由をチャットで報告する。必要な新知識は追加できるが、量を減らすために非自明な手順・判断基準は削らず、実行のたびに履歴ファイルを増やさない。

### 4. 検証

- 抽出した全知見を `反映済み / 既存で充足 / 見送り / handoff / 確認待ち / 承認待ち / 提案のみ` に分類し、反映先または理由と照合して未処理を残さない。対象外の知見は推奨先の確認済みなら `handoff`、未確認なら `確認待ち` とし、対象外という理由だけで `見送り` にしない。review-only の変更案は `提案のみ` とし、反映済みと報告しない。
- 変更箇所に応じたテスト / 診断を実行し、未検証項目は理由を明記する。

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
