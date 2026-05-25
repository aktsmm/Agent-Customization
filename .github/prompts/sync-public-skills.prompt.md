---
name: "sync-public-skills"
description: "セッションから得られた知見を 00_Ag-SkillBuilder のスキル・エージェントに反映し、公開リポジトリに同期"
---

<!-- syncToGlobal: true -->

# sync public skills

セッションで得た知見をスキルリポジトリに反映し、公開リポジトリに同期する。
**環境固有情報・顧客情報は含めないこと。**

## パス

| 用途 | パス |
| --- | --- |
| プライベート repo | `<private skill repo clone>` |
| 公開 repo | `<public skill repo clone>` |

| 種別 | 反映先（プライベート repo 内） |
| --- | --- |
| スキル | `.github/skills/` |

### ローカル override（任意）

この prompt は public-safe な placeholder を保持する。検索を省略したい場合だけ、以下の環境変数で local path を上書きしてよい。`$env:` に無くても、User スコープに定義済みのことがある。

| 変数 | 用途 |
| --- | --- |
| `SYNC_PUBLIC_SKILLS_PRIVATE_REPO` | private repo clone の絶対パス |
| `SYNC_PUBLIC_SKILLS_PUBLIC_REPO` | public repo clone の絶対パス |
| `SYNC_PUBLIC_SKILLS_SCRIPT` | `Sync-AndPush.ps1` の絶対パス |

環境変数はローカル専用 override として扱い、prompt 本文には実パスを埋め戻さない。PowerShell では Process に無ければ User スコープを読む。

```powershell
foreach ($name in 'SYNC_PUBLIC_SKILLS_PRIVATE_REPO','SYNC_PUBLIC_SKILLS_PUBLIC_REPO','SYNC_PUBLIC_SKILLS_SCRIPT') {
	if (-not $env:$name) { $env:$name = [System.Environment]::GetEnvironmentVariable($name, 'User') }
}
```

## 公開対象（blacklist 方式）

SSOT は `Sync-AndPush.ps1` の `$ExcludeSkills` 配列。`.github/skills/` 配下で `$ExcludeSkills` に含まれないものはすべて公開対象。
非公開にすべきケース: ライセンス未確認 / 顧客・社内情報 / 開発中 / 個人環境依存。

## 反映ルール

- **追記より更新・統合・置換を優先**
- 新規追加は既存に収まらない場合だけ
- 汎用化できない内容、単発メモ、同じ失敗の言い換えは反映しない
- 例やサンプルコマンドに固有イベント名、個人ユーザー名入りパス、組織内でしか通じない文脈が残る場合は、公開前に汎用例へ置換する
- 永続化する価値がなければ変更なしで終了してよい
- append-only に節や箇条書きを足し続けるのを通常運用とみなさない
- 変更前に `削除 → 統合 → 分離 → 追加` の順で検討する
- 既存 skill の main SKILL や references が長くなりすぎていないかを確認し、追記前に既存文の置換や圧縮で済まないかを見る
- 既定モードは `safe-auto`。公開不可情報・ライセンス不明・公開範囲変更・大規模削除・意味変更・判断に迷う点がなければ、反映 + 公開同期 + push まで自律実行してよい
- `review-only` / `確認だけ` / `dry-run` / `プレビュー` が明示された場合だけ、確認表示で停止する
- 大規模削除・意味変更・公開範囲変更・公開可否に迷う場合はユーザー確認で停止する
- co-batch の方針は Step 1.5 / 2.5 を参照。`git add -A` で repo 全体を巻き込まない

### 反映してよい / してはいけない

| OK | NG |
| --- | --- |
| 繰り返し使う手順・判断基準・失敗回避策 | 環境依存パス、アカウント、顧客・社内情報 |
| 既存ルールの抜け・古さの補正 | 既存ルールの言い換えだけで実質差分なし |
| 公開安全で他環境でも再利用可能 | 一時デバッグログ、単発メモ、公開品質未達 |

## 実行手順

### 1. 初期化

- まず Process スコープの override を確認し、無ければ User スコープの同名環境変数を現在のセッションへ補完して使う
- override が未設定、placeholder のまま、または `Test-Path` に失敗した場合だけ、repo 名検索へフォールバックする
- まずパス表の private / public repo と `scripts/Sync-AndPush.ps1` を `Test-Path` で確認する
- パス表が placeholder のまま、またはパスが存在しない場合は即停止せず、repo 名 `00_Ag-SkillBuilder` / `Agent-Skills` と `Sync-AndPush.ps1` を PowerShell でローカル検索する
- 1 件だけ見つかった場合はそのパスを使う。0 件または複数件なら、検索した範囲・候補・不足している確認事項を報告して停止する
- workspace-scoped search だけで repo 不在と断定しない

```powershell
Set-Location <private-skill-repo>; git branch --show-current; git status --short
```

### 1.5 dirty skill スキャン

- private repo の `.github/skills/` 配下の未コミット変更を skill 単位で列挙する
- 各 skill を以下に分類する
	- **primary candidate**: 今回の依頼で直接編集した skill
	- **co-batch candidate**: 今回の依頼外だが、公開安全で一緒に同期して問題ない skill
	- **blocked candidate**: ライセンス不明、公開可否不明、顧客/社内情報、意味変更が大きい、または差分意図が説明できない skill
- `safe-auto` では primary + co-batch をまとめて進めてよい。blocked は除外して理由を報告する
- dirty skill が 0 件なら通常どおり続行する

### 2. 差分収集 + 内部レビュー

#### 反映先ルーティング

- 知見候補を抽出したら、`.github/skills/*/SKILL.md` の `name` + `description` を走査し、各知見がどの skill の領域に属するかを判定する
- 1 skill に明確にマッチ → その skill の SKILL.md または references 配下が反映先
- 複数 skill にまたがる → 最も specific な skill を優先し、残りは別 skill への分割を検討
- **0 マッチ（既存 skill に収まらない）** → 「新規 skill 候補」フラグを立てて Step 3 で扱う

#### 内部レビュー

- セッションから知見候補を抽出
- ルーティング結果に基づき、既存ファイルとの重複・統合可能性を確認
- **統合候補 / 削除候補 / 追加候補** に分類（反映ルールの優先順に従う）
- 対象ファイルが「追記され続けて太っていないか」を確認する
- 追加候補は、追記ではなく既存文の置換・圧縮・reference への逃がしで解決できないかを先に検討する
- co-batch candidate も同じ基準でレビューし、primary と同じ品質基準を満たす場合だけ同梱する

### 2.5 co-batch gate

- co-batch candidate を含める場合は、skill ごとに 1 行で「何を変えたか」「なぜ今回一緒に流して安全か」を説明できること
- 依頼と無関係でも、公開安全で差分が小さく、同時同期の説明が立つなら同梱してよい
- 差分が大きい、レビュー不足、公開判断に迷う場合は blocked に落として今回の対象から外す

### 3. 反映

- 自律的に反映。影響が大きい場合、または公開判断に迷う場合のみユーザー確認
- README は入口情報が古くなる場合だけ更新（private / public 両方）

#### 新規 skill 候補の扱い

- Step 2 で「新規 skill 候補」フラグが立った知見は、`create-skill` skill または `agent-customization` skill に scaffold を委任する
- この prompt 内で scaffold 手順を再実装しない
- 新規 skill 作成後、blacklist 判定（公開可否）と README 更新要否を確認してから Step 3.5 以降に進む

### 3.5. 肥大化チェック（反映後）

- 反映後、編集したファイルに DRY 違反・冗長表現・重複定義がないか確認する
- `行数が増える = 改善` とみなさない。追加より圧縮・reference 分離を先に検討する
- 問題があれば修正し、報告に「⚠️ 肥大化警告」を含める

### 3.8. private repo への個別 commit / push

- `Sync-AndPush.ps1` 実行前に、primary + co-batch として採用した skill だけを明示的に stage して commit / push する
- 例: `git add .github/skills/skill-a .github/skills/skill-b`
- `git commit` は stage 済みの対象だけで行い、他の dirty skill は未 staged のまま残してよい
- その後の公開同期は `-SkipDevPush` を付けて実行する
- `git status --short` に対象外の dirty skill が残っていても、今回の採用 skill だけが commit 済みなら続行してよい

### 4. 公開同期

**必ず `Sync-AndPush.ps1` を使う**（直接コピー禁止）:

```powershell
.\scripts\Sync-AndPush.ps1 -Message "sync: <変更内容>" -SkipDevPush
```

同期後に `Get-ChildItem <public-skill-repo> | Select-Object Name` で構造確認。`skills/` フォルダが存在したらバグ → 即削除して push。

```powershell
Get-ChildItem <public-skill-repo> | Select-Object Name
```

`Sync-AndPush.ps1` がエラーで終了した場合は、エラー出力を確認し、手動コピーで代替しない。原因を解消してから再実行する。

### 5. 報告

1. 統合候補として扱ったもの
2. 削除候補として扱い、実際に削除または見送ったもの
3. 追加候補として扱い、実際に追加したもの
4. 追加しなかったものとその理由
5. co-batch として一緒に反映した skill と、その採用理由
6. blocked として今回除外した dirty skill と、その理由
7. 更新したファイル一覧
8. README 更新有無（更新しなかった場合は理由 1 行）

## 完了条件

- 反映候補が既存資産と重複していない
- 更新・統合・整理が追記より優先されている
- README 更新要否が確認済み
- 公開不可情報が含まれていない
- primary / co-batch / blocked の分類が済み、unsafe な dirty skill が巻き込まれていない
- private repo では採用した skill だけが個別 commit / push されている
- 全知見が反映先 / 新規 skill / 見送りのいずれかに分類済み
- 同期後の公開リポジトリ構造が正しい
- 判断に迷う懸念がなければ公開 repo への push まで完了している
