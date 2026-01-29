---
name: sync-to-global
description: テンプレート ⇔ グローバル設定を双方向同期（新しい方を残す）
tools: ["runInTerminal", "readFile"]
---

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
- ハッシュ値が異なる場合は差分あり
- タイムスタンプを比較して、どちらが新しいか表示
- 新しい方に `← NEWER` マークを付与

```powershell
$templateRoot = Get-Location
$globalRoot = "$env:APPDATA\Code\User"
$num = 0

function Compare-Files {
    param($templatePath, $globalPath, $relativePath)
    
    if (-not (Test-Path $globalPath)) {
        $script:num++
        Write-Host "[$script:num] [NEW] $relativePath" -ForegroundColor Green
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
- `auto` 選択時は新しい方を自動判定して双方向に同期。

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
```

---

## Configuration

- テンプレート: `.github/instructions_sync/`, `.github/prompts_sync/`, `.github/agents_sync/`
- グローバル: `$env:APPDATA\Code\User\instructions/`, `prompts/`
- パス変換: `instructions_sync` ⇔ `instructions`, `prompts_sync` ⇔ `prompts`, `agents_sync` ⇔ `prompts`

## Permissions

- ✅ ファイルの読み込み、双方向コピー
- ❌ `git push`、ユーザーの許可なきファイル削除

## References

- [Terminal Rules](../instructions_sync/dev/terminal.instructions.md)
- https://code.visualstudio.com/docs/copilot/customization/custom-instructions
