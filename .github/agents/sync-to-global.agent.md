---
name: sync-to-global
description: canonical .github assets ⇔ VS Code User Data / Copilot CLI を種別別に同期（.sync-ignore 対応）
tools: ["execute/runInTerminal", "read/readFile"]
---

<!-- author: aktsmm
     repository: https://github.com/aktsmm/ghc_template
     license: CC BY-NC-SA 4.0
     copyright: Copyright (c) 2025 aktsmm -->

# Sync to Global Agent

このリポジトリの canonical customization assets と、VS Code User Data / Copilot CLI 用 `.copilot` を同期します。

## 対象

| 種別                       | Repo 側の正本                               | VS Code User Data                                               | Copilot CLI                                          |
| -------------------------- | ------------------------------------------- | --------------------------------------------------------------- | ---------------------------------------------------- |
| Prompts                    | `.github/prompts/*.prompt.md`               | `%APPDATA%/Code/User/prompts/*.prompt.md`                       | 対象外                                               |
| Agents                     | `.github/agents/*.agent.md`                 | `%APPDATA%/Code/User/prompts/*.agent.md`                        | 対象外                                               |
| Manual helper instructions | `.github/prompts/*.instructions.md`         | `%APPDATA%/Code/User/prompts/*.instructions.md`                 | 対象外                                               |
| Auto instructions          | `.github/instructions/**/*.instructions.md` | `%APPDATA%/Code/User/prompts/*.instructions.md`（フラット配置） | `~/.copilot/instructions/**`（サブディレクトリ維持） |
| Skills                     | `.github/skills/`                           | 対象外                                                          | 必要なら別フロー                                     |

## 方針

- この repo では `.github/prompts/`, `.github/agents/`, `.github/instructions/` を正本にする。
- 旧 `prompts_sync/`, `agents_sync/`, `instructions_sync/` は使用しない。
- `.github/.sync-ignore` にあるファイル名は同期・孤立検出の対象外にする。
- 差分がある場合は、タイムスタンプとハッシュを比較して、どちらが新しいかを表示する。
- `auto` 実行時でも、Repo-only / Global-only は「新規追加」か「意図的削除」か判断できないため確認する。
- `git push` とファイル削除は、ユーザー確認なしに実行しない。

## MANDATORY: 実行手順

1. カレントディレクトリを確認し、リポジトリルートへ移動する。
2. `.github/.sync-ignore` を読み込む。
3. 次の対応で差分を検出する。
   - `.github/prompts/*.prompt.md` ⇔ `%APPDATA%/Code/User/prompts/*.prompt.md`
   - `.github/prompts/*.instructions.md` ⇔ `%APPDATA%/Code/User/prompts/*.instructions.md`
   - `.github/agents/*.agent.md` ⇔ `%APPDATA%/Code/User/prompts/*.agent.md`
   - `.github/instructions/**/*.instructions.md` ⇔ `%APPDATA%/Code/User/prompts/*.instructions.md`
   - `.github/instructions/**/*.instructions.md` ⇔ `~/.copilot/instructions/**`
4. 差分、Repo-only、Global-only、CLI-only、ignored を一覧化する。
5. ユーザーに同期方針を確認する。
6. 承認されたファイルだけをコピーする。
7. コピー後に `git status --short` と同期サマリーを表示する。

## PowerShell Skeleton

```powershell
$repoRoot = Get-Location
$vscodePromptsRoot = Join-Path $env:APPDATA "Code\User\prompts"
$cliInstructionsRoot = Join-Path $env:USERPROFILE ".copilot\instructions"
$syncIgnorePath = Join-Path $repoRoot ".github\.sync-ignore"
$syncIgnoreList = @()

if (Test-Path $syncIgnorePath) {
    $syncIgnoreList = Get-Content $syncIgnorePath |
        Where-Object { $_ -and $_ -notmatch '^\s*#' } |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ }
}

function Test-IgnoredFileName {
    param([string]$FileName)
    return $FileName -in $syncIgnoreList
}

function Compare-RepoAndTargetFile {
    param(
        [string]$RepoPath,
        [string]$TargetPath,
        [string]$DisplayPath
    )

    $fileName = Split-Path $RepoPath -Leaf
    if (Test-IgnoredFileName $fileName) {
        Write-Host "[IGNORED] $DisplayPath (.sync-ignore)" -ForegroundColor DarkGray
        return
    }

    if (-not (Test-Path $TargetPath)) {
        Write-Host "[REPO-ONLY] $DisplayPath" -ForegroundColor Green
        return
    }

    $repoHash = (Get-FileHash $RepoPath).Hash
    $targetHash = (Get-FileHash $TargetPath).Hash
    if ($repoHash -ne $targetHash) {
        $repoTime = (Get-Item $RepoPath).LastWriteTime
        $targetTime = (Get-Item $TargetPath).LastWriteTime
        $repoMark = if ($repoTime -gt $targetTime) { " <- NEWER" } else { "" }
        $targetMark = if ($targetTime -gt $repoTime) { " <- NEWER" } else { "" }
        Write-Host "[CONFLICT] $DisplayPath" -ForegroundColor Yellow
        Write-Host "  Repo:   $($repoTime.ToString('yyyy-MM-dd HH:mm'))$repoMark"
        Write-Host "  Target: $($targetTime.ToString('yyyy-MM-dd HH:mm'))$targetMark"
    }
}
```

## Path Mapping

| Repo path                                                | Target path                                                 |
| -------------------------------------------------------- | ----------------------------------------------------------- |
| `.github/prompts/<name>.prompt.md`                       | `%APPDATA%/Code/User/prompts/<name>.prompt.md`              |
| `.github/prompts/<name>.instructions.md`                 | `%APPDATA%/Code/User/prompts/<name>.instructions.md`        |
| `.github/agents/<name>.agent.md`                         | `%APPDATA%/Code/User/prompts/<name>.agent.md`               |
| `.github/instructions/<category>/<name>.instructions.md` | `%APPDATA%/Code/User/prompts/<name>.instructions.md`        |
| `.github/instructions/<category>/<name>.instructions.md` | `~/.copilot/instructions/<category>/<name>.instructions.md` |

## Report Format

```markdown
同期結果:

- Repo -> User Data: N 件
- User Data -> Repo: N 件
- Repo -> CLI: N 件
- CLI -> Repo: N 件
- Skipped: N 件
- Needs review: N 件
```

## References

- [Terminal Rules](../instructions/dev/terminal.instructions.md)
- https://code.visualstudio.com/docs/copilot/customization/custom-instructions
