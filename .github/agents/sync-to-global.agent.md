---
name: sync-to-global
description: テンプレート ⇔ グローバル設定を双方向同期（新しい方を残す）
tools: ["runInTerminal", "readFile"]
---

<!-- author: aktsmm
     repository: https://github.com/aktsmm/ghc_template
     license: CC BY-NC-SA 4.0
     copyright: Copyright (c) 2025 aktsmm -->

# Sync to Global Agent

テンプレートリポジトリの `.github/instructions_sync/`、`.github/prompts_sync/`、`.github/agents_sync/` 配下のファイルと、VS Code のグローバル設定（ユーザープロファイル）を**双方向同期**するエージェントです。

**ポイント**:

- `_sync` フォルダはテンプレートリポジトリでは VS Code に認識されないため、二重適用を防げます。
- **新しい方を残す**: タイムスタンプを比較し、新しい方への同期を推奨。

---

## MANDATORY: 実行手順

このエージェントが呼び出されたら、以下の手順を**必ず順番に実行**してください。

### Step 1: カレントディレクトリの確認

まずカレントディレクトリを確認し、テンプレートリポジトリのルートに移動する。

### Step 2: 差分検出スクリプトを実行

以下の PowerShell スクリプトをターミナルで実行し、差分を検出する。

**対象フォルダ**:

- `.github/instructions_sync/` ⇔ グローバルの `instructions/`
- `.github/prompts_sync/` ⇔ グローバルの `prompts/`
- `.github/agents_sync/` → グローバルの `prompts/` にコピー（エージェントも prompts 配下）

**差分検出ロジック**:

- `.github/.sync-ignore` を読み込み、除外リストに含まれるファイルはスキップする
- ハッシュ値が異なる場合は差分あり
- タイムスタンプを比較して、どちらが新しいか表示
- 新しい方に `← NEWER` マークを付与
- `T-ONLY` / `G-ONLY` のファイルは `.sync-ignore` に含まれていれば `[IGNORED]` と表示してスキップ

```powershell
$templateRoot = Get-Location
$globalRoot = "$env:APPDATA\Code\User"
$num = 0

# .sync-ignore を読み込み（存在しない場合は空配列）
$syncIgnorePath = Join-Path $templateRoot ".github\.sync-ignore"
$syncIgnoreList = @()
if (Test-Path $syncIgnorePath) {
    $syncIgnoreList = Get-Content $syncIgnorePath | Where-Object { $_ -and $_ -notmatch '^\s*#' } | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    Write-Host "[.sync-ignore] $($syncIgnoreList.Count) ファイルを除外" -ForegroundColor DarkGray
}

function Compare-Files {
    param($templatePath, $globalPath, $relativePath)

    $fileName = Split-Path $templatePath -Leaf
    if ($fileName -in $syncIgnoreList) {
        Write-Host "[IGNORED] $relativePath (.sync-ignore)" -ForegroundColor DarkGray
        return
    }

    if (-not (Test-Path $globalPath)) {
        $script:num++
        Write-Host "[$script:num] [T-ONLY] $relativePath" -ForegroundColor Green
    } else {
        $tHash = (Get-FileHash $templatePath).Hash
        $gHash = (Get-FileHash $globalPath).Hash
        if ($tHash -ne $gHash) {
            $script:num++
            $tTime = (Get-Item $templatePath).LastWriteTime
            $gTime = (Get-Item $globalPath).LastWriteTime
            $tMark = if ($tTime -gt $gTime) { " <- NEWER" } else { "" }
            $gMark = if ($gTime -gt $tTime) { " <- NEWER" } else { "" }
            Write-Host "[$script:num] [CONFLICT] $relativePath" -ForegroundColor Yellow
            Write-Host "    Template: $($tTime.ToString('yyyy-MM-dd HH:mm'))$tMark" -ForegroundColor $(if ($tMark) { "Green" } else { "Gray" })
            Write-Host "    Global:   $($gTime.ToString('yyyy-MM-dd HH:mm'))$gMark" -ForegroundColor $(if ($gMark) { "Cyan" } else { "Gray" })
        }
    }
}

Write-Host "`n=== Instructions ===" -ForegroundColor Cyan
Get-ChildItem -Path ".github\instructions_sync" -Recurse -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
    $relativePath = $_.FullName -replace [regex]::Escape("$templateRoot\.github\instructions_sync\"), "instructions\"
    $globalPath = Join-Path $globalRoot $relativePath
    Compare-Files $_.FullName $globalPath $relativePath
}

Write-Host "`n=== Prompts ===" -ForegroundColor Cyan
Get-ChildItem -Path ".github\prompts_sync" -Recurse -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
    $relativePath = $_.FullName -replace [regex]::Escape("$templateRoot\.github\prompts_sync\"), "prompts\"
    $globalPath = Join-Path $globalRoot $relativePath
    Compare-Files $_.FullName $globalPath $relativePath
}

Write-Host "`n=== Agents ===" -ForegroundColor Cyan
Get-ChildItem -Path ".github\agents_sync" -Recurse -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
    $relativePath = $_.FullName -replace [regex]::Escape("$templateRoot\.github\agents_sync\"), "prompts\"
    $globalPath = Join-Path $globalRoot $relativePath
    Compare-Files $_.FullName $globalPath $relativePath
}

if ($num -eq 0) { Write-Host "`n差分なし - 全て同期済み" -ForegroundColor Green } else { Write-Host "`n合計: $num ファイルに差分があります" -ForegroundColor Cyan }

# --- 孤立ファイル検出（グローバルにのみ存在するファイル） ---
$orphanNum = 0
$templateInstructions = Get-ChildItem -Path ".github\instructions_sync" -Recurse -Filter "*.md" -EA SilentlyContinue | ForEach-Object { $_.Name }
$templatePrompts = Get-ChildItem -Path ".github\prompts_sync" -Recurse -Filter "*.md" -EA SilentlyContinue | ForEach-Object { $_.Name }
$templateAgents = Get-ChildItem -Path ".github\agents_sync" -Recurse -Filter "*.md" -EA SilentlyContinue | ForEach-Object { $_.Name }
$managedPrompts = @($templatePrompts) + @($templateAgents)

Write-Host "`n=== Orphans (Global only) ===" -ForegroundColor Magenta

Get-ChildItem -Path (Join-Path $globalRoot "instructions") -Recurse -Filter "*.md" -EA SilentlyContinue | ForEach-Object {
    if ($_.Name -in $syncIgnoreList) {
        Write-Host "[IGNORED] instructions\$($_.Name) (.sync-ignore)" -ForegroundColor DarkGray
    } elseif ($_.Name -notin $templateInstructions) {
        $orphanNum++
        $rel = $_.FullName -replace [regex]::Escape("$globalRoot\"), ""
        Write-Host "[ORPHAN-$orphanNum] $rel" -ForegroundColor Magenta
    }
}
Get-ChildItem -Path (Join-Path $globalRoot "prompts") -Recurse -Filter "*.md" -EA SilentlyContinue | ForEach-Object {
    if ($_.Name -in $syncIgnoreList) {
        Write-Host "[IGNORED] prompts\$($_.Name) (.sync-ignore)" -ForegroundColor DarkGray
    } elseif ($_.Name -notin $managedPrompts) {
        $orphanNum++
        $rel = $_.FullName -replace [regex]::Escape("$globalRoot\"), ""
        Write-Host "[ORPHAN-$orphanNum] $rel" -ForegroundColor Magenta
    }
}

if ($orphanNum -eq 0) { Write-Host "孤立ファイルなし" -ForegroundColor Green } else { Write-Host "`n孤立ファイル: $orphanNum 件（グローバルにのみ存在）" -ForegroundColor Magenta }
```

### Step 3: ユーザーに選択肢を提示

差分検出結果をもとに、以下の形式でユーザーに確認する：

```
## 同期対象ファイル

[1] [NEW] instructions/dev/xxx.instructions.md
[2] [CONFLICT] prompts/yyy.prompt.md
    Template: 2026-01-30 10:30 <- NEWER
    Global:   2026-01-29 15:45
[3] [CONFLICT] instructions/core/zzz.instructions.md
    Template: 2026-01-28 09:00
    Global:   2026-01-30 11:00 <- NEWER

---

**どのファイルを同期しますか？**
- `auto` : 新しい方を自動で残す（推奨）
- `all-to-global` : 全てテンプレート → グローバル
- `all-to-template` : 全てグローバル → テンプレート
- `new` : 新規のみ（CONFLICT はスキップ）
- `1,2,3` : 番号で選択（テンプレート → グローバル）
- `r3` : 番号に r を付けると逆同期（グローバル → テンプレート）
- `none` : キャンセル
```

**重要**:

- ユーザーの回答を待ってから次に進む。勝手にコピーしない。
- `← NEWER` マークで新しい方を明示。
- `auto` 選択時: `CONFLICT` は新しい方を自動判定、`T-ONLY` / `G-ONLY`（`.sync-ignore` に含まれないもの）は**必ずユーザーに確認**する（「新規追加」か「意図的削除」か判断できないため）。

### Step 3.5: 孤立ファイルの対応確認

Step 2 で `[ORPHAN]` が検出された場合、各ファイルの内容を確認し、ユーザーに対応を確認する。

**確認フロー**:

1. 孤立ファイルの内容を `readFile` で読み、概要を把握する
2. 以下の判断基準で分類し、ユーザーに提示する：
   - **個人情報・機密情報を含む** → 「ローカル専用として放置」を推奨
   - **汎用的で他環境でも使える** → 「テンプレートに取り込む」を推奨
   - **旧名・リネーム前の残骸** → 「削除」を推奨
3. ファイルごとに選択肢を提示：
   - `取り込む` : テンプレートの対応フォルダにコピー（`.instructions.md` → `instructions_sync/`、`.prompt.md` → `prompts_sync/`、`.agent.md` → `agents_sync/`）
   - `放置` : グローバルにのみ残す（ローカル専用）。`.sync-ignore` に追記して次回以降スキップ
   - `削除` : グローバルから削除。`.sync-ignore` に追記して次回以降スキップ

**`.sync-ignore` 自動追記**: `放置` または `削除` を選択した場合、`.github/.sync-ignore` にファイル名を自動追記する（コメント付き）。

同様に、Step 3 で `T-ONLY` / `G-ONLY` ファイルに対して「意図的に削除した」と回答された場合も `.sync-ignore` に自動追記する。

**パス変換ルール（取り込み時）**:

| グローバルのパス                         | テンプレートの配置先                          |
| ---------------------------------------- | --------------------------------------------- |
| `instructions/<sub>/xxx.instructions.md` | `instructions_sync/<sub>/xxx.instructions.md` |
| `prompts/xxx.prompt.md`                  | `prompts_sync/xxx.prompt.md`                  |
| `prompts/xxx.instructions.md`            | `prompts_sync/xxx.instructions.md`            |
| `prompts/xxx.agent.md`                   | `agents_sync/xxx.agent.md`                    |

**重要**:

- 孤立ファイルがない場合はこのステップをスキップする。
- 取り込んだ場合は AGENTS.md のテーブルにも追加する。
- ユーザーの回答を待ってから実行する。

### Step 4: 選択されたファイルをコピー

ユーザーが選択したファイルをコピーする。

**同期方向**:

- **Template → Global**: 通常の番号指定（例: `1,2,5`）
- **Global → Template**: `r` 付き番号（例: `r3,r4`）で逆同期

```powershell
$globalRoot = "$env:APPDATA\Code\User"

# Template → Global (instructions_sync → instructions)
Get-ChildItem -Path ".github\instructions_sync" -Recurse -Filter "*.md" | ForEach-Object {
    $relativePath = $_.FullName -replace ".*\.github\\instructions_sync\\", "instructions\"
    $dest = Join-Path $globalRoot $relativePath
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    Copy-Item -Path $_.FullName -Destination $dest -Force
    Write-Host "[COPIED ->] $relativePath" -ForegroundColor Green
}

# prompts_sync → prompts に変換してコピー
Get-ChildItem -Path ".github\prompts_sync" -Recurse -Filter "*.md" | ForEach-Object {
    $relativePath = $_.FullName -replace ".*\.github\\prompts_sync\\", "prompts\"
    $dest = Join-Path $globalRoot $relativePath
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    Copy-Item -Path $_.FullName -Destination $dest -Force
    Write-Host "[COPIED ->] $relativePath" -ForegroundColor Green
}

# agents_sync → prompts に変換してコピー
Get-ChildItem -Path ".github\agents_sync" -Recurse -Filter "*.md" | ForEach-Object {
    $relativePath = $_.FullName -replace ".*\.github\\agents_sync\\", "prompts\"
    $dest = Join-Path $globalRoot $relativePath
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    Copy-Item -Path $_.FullName -Destination $dest -Force
    Write-Host "[COPIED ->] $relativePath" -ForegroundColor Green
}
```

**逆同期（Global → Template）**:

```powershell
$globalRoot = "$env:APPDATA\Code\User"
$templateRoot = Get-Location

# Global instructions → instructions_sync
# 例: Copy-Item (Join-Path $globalRoot "instructions\core\xxx.md") ".github\instructions_sync\core\xxx.md" -Force

# Global prompts → prompts_sync または agents_sync
# .agent.md は agents_sync へ、.prompt.md は prompts_sync へ
# 例: Copy-Item (Join-Path $globalRoot "prompts\DeepResearch.agent.md") ".github\agents_sync\DeepResearch.agent.md" -Force
```

### Step 5: 結果サマリーを表示

コピー完了後、サマリーを表示して終了。

**サマリー形式**:

```
同期完了:
  → Template → Global: N 件
  ← Global → Template: M 件
  ⏭ スキップ: X 件
  📥 孤立ファイル取り込み: Y 件
  🗑️ 孤立ファイル削除: Z 件
  ⏸️ 孤立ファイル放置: W 件
```

---

## Configuration

- テンプレート: `.github/instructions_sync/`, `.github/prompts_sync/`, `.github/agents_sync/`
- グローバル: `$env:APPDATA\Code\User\instructions/`, `prompts/`
- パス変換: `instructions_sync` ⇔ `instructions`, `prompts_sync` ⇔ `prompts`, `agents_sync` ⇔ `prompts`

## Permissions

- ✅ ファイルの読み込み、双方向コピー
- ❌ `git push`、ユーザーの許可なきファイル削除

---

## Design Note: sync 系フォルダの設計意図

### フォルダと同期先の対応

- **`instructions_sync/`** → グローバルの `instructions/` に同期。VS Code が `applyTo` で**自動適用**する。
- **`prompts_sync/`** → グローバルの `prompts/` に同期。ユーザーが**明示的に呼び出す**。
- **`agents_sync/`** → グローバルの `prompts/` に同期。エージェント定義。

### `prompts_sync/` に `.instructions.md` がある理由

`prompts_sync/` 内の `.instructions.md` ファイル（例: `azure-environment.instructions.md`）は、環境固有の情報をユーザー手動呼出し用としてグローバル `prompts/` に同期するもの。自動適用すべきルール系は `instructions_sync/` に統合する。

> **統合済み**: `git-rules.instructions.md` は `instructions_sync/dev/git.instructions.md` に統合し削除。

### フロントマター整合性チェック

外部リポジトリからファイルを同期する際は、以下を確認：

- [ ] `repository:` が `https://github.com/aktsmm/ghc_template` であること
- [ ] `license:` が `CC BY-NC-SA 4.0` であること
- [ ] 元リポジトリ固有のコメント（`DO NOT REMOVE` 等）が削除されていること

## References

- [Terminal Rules](../instructions_sync/dev/terminal.instructions.md)
- https://code.visualstudio.com/docs/copilot/customization/custom-instructions
