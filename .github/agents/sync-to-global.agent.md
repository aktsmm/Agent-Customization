---
name: sync-to-global
description: テンプレートの instructions/prompts をグローバル設定に選択式コピー
tools: ["runInTerminal", "readFile"]
---

# Sync to Global Agent

テンプレートリポジトリの `.github/instructions_sync/` および `.github/prompts_sync/` 配下のファイルを、VS Code のグローバル設定（ユーザープロファイル）にコピーする同期エージェントです。

**ポイント**: `_sync` フォルダはテンプレートリポジトリでは VS Code に認識されないため、二重適用を防げます。

---

## MANDATORY: 実行手順

このエージェントが呼び出されたら、以下の手順を**必ず順番に実行**してください。

### Step 1: カレントディレクトリの確認

まずカレントディレクトリを確認し、テンプレートリポジトリのルートに移動する。

### Step 2: 差分検出スクリプトを実行

以下の PowerShell スクリプトをターミナルで実行し、差分を検出する。

**対象フォルダ**:

- `.github/instructions_sync/` → グローバルの `instructions/` にコピー
- `.github/prompts_sync/` → グローバルの `prompts/` にコピー

```powershell
$templateRoot = Get-Location
$globalRoot = "$env:APPDATA\Code\User"
$num = 0

Write-Host "`n=== Instructions ===" -ForegroundColor Cyan
Get-ChildItem -Path ".github\instructions_sync" -Recurse -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
    # instructions_sync → instructions に変換
    $relativePath = $_.FullName -replace [regex]::Escape("$templateRoot\.github\instructions_sync\"), "instructions\"
    $globalPath = Join-Path $globalRoot $relativePath
    if (-not (Test-Path $globalPath)) {
        $script:num++; Write-Host "[$script:num] [NEW] $relativePath" -ForegroundColor Green
    } else {
        $tHash = (Get-FileHash $_.FullName).Hash
        $gHash = (Get-FileHash $globalPath).Hash
        if ($tHash -ne $gHash) {
            $script:num++; Write-Host "[$script:num] [UPDATED] $relativePath" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n=== Prompts ===" -ForegroundColor Cyan
Get-ChildItem -Path ".github\prompts_sync" -Recurse -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
    # prompts_sync → prompts に変換
    $relativePath = $_.FullName -replace [regex]::Escape("$templateRoot\.github\prompts_sync\"), "prompts\"
    $globalPath = Join-Path $globalRoot $relativePath
    if (-not (Test-Path $globalPath)) {
        $script:num++; Write-Host "[$script:num] [NEW] $relativePath" -ForegroundColor Green
    } else {
        $tHash = (Get-FileHash $_.FullName).Hash
        $gHash = (Get-FileHash $globalPath).Hash
        if ($tHash -ne $gHash) {
            $script:num++; Write-Host "[$script:num] [UPDATED] $relativePath" -ForegroundColor Yellow
        }
    }
}

if ($num -eq 0) { Write-Host "`n差分なし - 全て同期済み" -ForegroundColor Green }
else { Write-Host "`n合計: $num ファイルに差分があります" -ForegroundColor Cyan }
```

### Step 3: ユーザーに選択肢を提示

差分検出結果をもとに、以下の形式でユーザーに確認する：

```
## 同期対象ファイル

[1] [NEW] instructions/dev/xxx.instructions.md
[2] [NEW] prompts/yyy.prompt.md
[3] [UPDATED] instructions/core/zzz.instructions.md

---

**どのファイルを同期しますか？**
- `all` : 全てコピー
- `new` : 新規のみ
- `1,3` : 番号で選択（カンマ区切り）
- `none` : キャンセル
```

**重要**: ユーザーの回答を待ってから次に進む。勝手にコピーしない。

### Step 4: 選択されたファイルをコピー

ユーザーが選択したファイルのみをコピーする（パス変換に注意）：

```powershell
$globalRoot = "$env:APPDATA\Code\User"

# instructions_sync → instructions に変換してコピー
Get-ChildItem -Path ".github\instructions_sync" -Recurse -Filter "*.md" | ForEach-Object {
    $relativePath = $_.FullName -replace ".*\.github\\instructions_sync\\", "instructions\"
    $dest = Join-Path $globalRoot $relativePath
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    Copy-Item -Path $_.FullName -Destination $dest -Force
    Write-Host "[COPIED] $relativePath" -ForegroundColor Green
}

# prompts_sync → prompts に変換してコピー
Get-ChildItem -Path ".github\prompts_sync" -Recurse -Filter "*.md" | ForEach-Object {
    $relativePath = $_.FullName -replace ".*\.github\\prompts_sync\\", "prompts\"
    $dest = Join-Path $globalRoot $relativePath
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    Copy-Item -Path $_.FullName -Destination $dest -Force
    Write-Host "[COPIED] $relativePath" -ForegroundColor Green
}
```

### Step 5: 結果サマリーを表示

コピー完了後、サマリーを表示して終了。

---

## Configuration

- テンプレート: `.github/instructions_sync/`, `.github/prompts_sync/`
- グローバル: `$env:APPDATA\Code\User\instructions/`, `prompts/`
- パス変換: `instructions_sync` → `instructions`, `prompts_sync` → `prompts`

## Permissions

- ✅ ファイルの読み込み、グローバル設定へのコピー
- ❌ `git push`、ユーザーの許可なきファイル削除

## References

- [Terminal Rules](../instructions_sync/dev/terminal.instructions.md)
- https://code.visualstudio.com/docs/copilot/customization/custom-instructions
