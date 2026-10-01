<#
.SYNOPSIS
    Mirror public-safe VS Code User Data customizations into the GitHub customization repo.
.DESCRIPTION
    Default is read-only: precheck, classify, compare (case-sensitive, EOL-normalized), audit,
    and report. With -Apply it copies only the changed public-safe files, stages explicit
    paths, commits and pushes, then re-verifies the whole mirror.
    Deletion candidates are reported only; they are never removed automatically.
.EXAMPLE
    .\scripts\Sync-UserCustomizations.ps1            # report only
    .\scripts\Sync-UserCustomizations.ps1 -Apply     # mirror + commit + push
#>
[CmdletBinding()]
param(
    [string]$RepoDir = '',
    [string]$Source = (Join-Path $env:APPDATA 'Code\User\prompts'),
    [string]$Message = 'chore(sync): mirror user customizations',
    [string]$ExpectedGitHubRepo = '',
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
$SelfPrompt = 'sync-user-customizations-to-github.prompt.md'
$Kinds = @('.prompt.md', '.instructions.md', '.agent.md')

function Resolve-Env([string]$Name) {
    $value = [Environment]::GetEnvironmentVariable($Name, 'Process')
    if (-not $value) { $value = [Environment]::GetEnvironmentVariable($Name, 'User') }
    $value
}

function ConvertTo-Normalized([string]$Text) { ($Text -replace '\r\n?', "`n").TrimEnd("`n") }

function Invoke-Git {
    param([string[]]$GitArgs, [switch]$AllowFailure)
    $out = @(& git -C $script:RepoDir @GitArgs 2>&1)
    if ($LASTEXITCODE -ne 0 -and -not $AllowFailure) { throw "git $($GitArgs -join ' ') failed: $($out -join ' ')" }
    $out
}

# Audit rules mirror the prompt: keys, credentials, token shapes, labeled GUIDs, e-mail addresses.
$AuditRules = [ordered]@{
    privateKey  = '-----BEGIN [A-Z ]*PRIVATE KEY-----'
    credential  = '(?i)(api[_-]?key|client[_-]?secret|password|passwd|refresh[_-]?token|connection ?string)\s*[:=]\s*["'']?[A-Za-z0-9_/+=\-]{12,}'
    tokenShape  = '(ghp_|gho_|ghu_|ghs_|github_pat_|xox[baprs]-|AKIA[0-9A-Z]{12,}|sk-[A-Za-z0-9]{20,}|eyJ[A-Za-z0-9_-]{15,}\.[A-Za-z0-9_-]{10,}\.)'
    labeledGuid = '(?i)(tenant|subscription|client|object|app(lication)?|directory|principal)[ _-]?(id)?\s*[:=]\s*["'']?[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
    email       = '[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z]{2,}'
}

function Get-AuditHits([string]$Label, [string]$Text) {
    foreach ($rule in $AuditRules.Keys) {
        foreach ($m in [regex]::Matches($Text, $AuditRules[$rule])) {
            [pscustomobject]@{ file = $Label; rule = $rule; match = $m.Value.Substring(0, [math]::Min(40, $m.Value.Length)) }
        }
    }
}

function Get-SyncPlan {
    $ignore = @()
    $ignoreFile = Join-Path $script:RepoDir '.github\.sync-ignore'
    if (Test-Path -LiteralPath $ignoreFile) {
        $ignore = @(Get-Content -LiteralPath $ignoreFile -Encoding UTF8 | Where-Object { $_.Trim() -and -not $_.TrimStart().StartsWith('#') } | ForEach-Object { $_.Trim() })
    }
    $instructionIndex = @{}
    $instructionRoot = Join-Path $script:RepoDir '.github\instructions'
    if (Test-Path -LiteralPath $instructionRoot) {
        Get-ChildItem -LiteralPath $instructionRoot -Recurse -File -Filter '*.instructions.md' | ForEach-Object {
            if (-not $instructionIndex.ContainsKey($_.Name)) { $instructionIndex[$_.Name] = @() }
            $instructionIndex[$_.Name] += $_.FullName
        }
    }
    $files = Get-ChildItem -LiteralPath $Source -File | Where-Object { $n = $_.Name; @($Kinds | Where-Object { $n.EndsWith($_) }).Count -gt 0 }
    foreach ($f in $files) {
        $text = [IO.File]::ReadAllText($f.FullName)
        $class =
            if ($f.Name -ceq $SelfPrompt) { 'self' }
            elseif ($f.Name -in $ignore) { 'ignored' }
            elseif ($text -match 'syncToGlobal:\s*true') { 'public-safe' }
            elseif ($text -match 'syncToGlobal:\s*false') { 'local-only' }
            else { 'needs-review' }
        $dest = $null
        $note = ''
        if ($class -eq 'public-safe') {
            if ($f.Name.EndsWith('.prompt.md')) { $dest = Join-Path $script:RepoDir ".github\prompts\$($f.Name)" }
            elseif ($f.Name.EndsWith('.agent.md')) { $dest = Join-Path $script:RepoDir ".github\agents\$($f.Name)" }
            else {
                $candidates = @($instructionIndex[$f.Name])
                if ($candidates.Count -eq 1) { $dest = $candidates[0] }
                elseif ($candidates.Count -gt 1) { $note = 'multiple mirror paths' }
                else { $note = 'no existing category' }
            }
        }
        $status =
            if ($class -ne 'public-safe') { 'excluded' }
            elseif (-not $dest) { 'needs-review' }
            elseif (-not (Test-Path -LiteralPath $dest)) { 'NEW' }
            elseif ((ConvertTo-Normalized $text) -cne (ConvertTo-Normalized ([IO.File]::ReadAllText($dest)))) { 'CHANGED' }
            else { 'same' }
        [pscustomobject]@{ name = $f.Name; class = $class; status = $status; note = $note; source = $f.FullName; dest = $dest }
    }
}

if (-not $RepoDir) { $RepoDir = Resolve-Env 'SYNC_USER_CUSTOMIZATIONS_REPO_DIR' }
if (-not $RepoDir -or -not (Test-Path -LiteralPath $RepoDir)) { throw 'Repo dir is unset or missing: pass -RepoDir or set SYNC_USER_CUSTOMIZATIONS_REPO_DIR.' }
$script:RepoDir = (Resolve-Path -LiteralPath $RepoDir).Path
$Source = (Resolve-Path -LiteralPath $Source).Path

# 1. Precheck
$branch = (Invoke-Git @('branch', '--show-current') | Select-Object -First 1).Trim()
$origin = (Invoke-Git @('remote', 'get-url', 'origin') | Select-Object -First 1).Trim()
$expected = if ($ExpectedGitHubRepo) { $ExpectedGitHubRepo } else { Resolve-Env 'SYNC_USER_CUSTOMIZATIONS_GITHUB_REPO' }
if ($expected -and $origin -notmatch [regex]::Escape($expected)) { throw "origin '$origin' does not match SYNC_USER_CUSTOMIZATIONS_GITHUB_REPO '$expected'." }
$dirty = @(Invoke-Git @('status', '--porcelain'))
Invoke-Git @('fetch', 'origin') | Out-Null
$counts = (Invoke-Git @('rev-list', '--left-right', '--count', "HEAD...refs/remotes/origin/$branch") | Select-Object -First 1).Trim()
Write-Host "repo: $script:RepoDir  branch: $branch  origin: $origin"
Write-Host "dirty(user-owned): $($dirty.Count)  ahead/behind: $counts"
if ($dirty.Count) { Write-Warning 'Existing uncommitted changes are user-owned and will not be mixed in.'; $dirty | ForEach-Object { Write-Host "  $_" } }

# 2. Plan + classify
$plan = @(Get-SyncPlan)
$candidates = @($plan | Where-Object { $_.status -in 'NEW', 'CHANGED' })
$review = @($plan | Where-Object { $_.status -eq 'needs-review' -or $_.class -eq 'needs-review' })
Write-Host ("classes: " + (($plan | Group-Object class | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join ', '))
Write-Host ("status:  " + (($plan | Group-Object status | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join ', '))
$candidates | ForEach-Object { Write-Host ("  {0,-8} {1}  -> {2}" -f $_.status, $_.name, $(if ($_.dest) { $_.dest.Substring($script:RepoDir.Length + 1) } else { '(new)' })) }
$review | ForEach-Object { Write-Warning "needs-review: $($_.name) $($_.note)" }

# Deletion candidates are report-only: a repo-only asset cannot be told apart from a stale mirror.
$sourceNames = @(Get-ChildItem -LiteralPath $Source -File | ForEach-Object { $_.Name })
$orphans = @(
    foreach ($dir in '.github\prompts', '.github\agents', '.github\instructions') {
        $full = Join-Path $script:RepoDir $dir
        if (Test-Path -LiteralPath $full) {
            Get-ChildItem -LiteralPath $full -Recurse -File | Where-Object { $n = $_.Name; @($Kinds | Where-Object { $n.EndsWith($_) }).Count -gt 0 -and $n -notin $sourceNames } | ForEach-Object { $_.FullName.Substring($script:RepoDir.Length + 1) }
        }
    })
Write-Host "deletion candidates (report only): $($orphans.Count)"
$orphans | ForEach-Object { Write-Host "  $_" }

# 3. Audit changed candidates (source) and their current destinations once.
$hits = @(foreach ($c in $candidates) {
    Get-AuditHits "source:$($c.name)" ([IO.File]::ReadAllText($c.source))
    if ($c.dest -and (Test-Path -LiteralPath $c.dest)) { Get-AuditHits "repo:$($c.name)" ([IO.File]::ReadAllText($c.dest)) }
})
if ($hits.Count) {
    $hits | Format-Table -AutoSize | Out-String | Write-Host
    throw "Audit found $($hits.Count) suspicious value(s). Stopping before any write."
}
Write-Host "audit: PASS ($($candidates.Count) candidate file(s))"

if (-not $Apply) { Write-Host 'Report only. Re-run with -Apply to mirror, commit and push.'; return }
if ($candidates.Count -eq 0) { Write-Host 'Nothing to mirror.'; return }
if ($dirty.Count) { throw 'Refusing to commit: the repo has existing uncommitted changes that cannot be separated.' }
if ($counts -notmatch '^0\s+0$') { throw "Repo is not current with origin/$branch ($counts)." }

# 4. Mirror, stage explicit paths, commit, push
$relative = foreach ($c in $candidates) {
    if (-not $c.dest) { throw "Unresolved destination for $($c.name)" }
    Copy-Item -LiteralPath $c.source -Destination $c.dest -Force
    $c.dest.Substring($script:RepoDir.Length + 1).Replace('\', '/')
}
Invoke-Git (@('add', '--') + @($relative)) | Out-Null
$staged = @(Invoke-Git @('diff', '--cached', '--name-only'))
if ($staged.Count -ne @($relative).Count -or @($staged | Where-Object { $_ -notin $relative }).Count) { throw "Staged set mismatch: $($staged -join ', ')" }
Invoke-Git @('diff', '--cached', '--check') | Out-Null
Invoke-Git @('commit', '-q', '-m', $Message) | Out-Null
Invoke-Git @('fetch', 'origin') | Out-Null
$after = (Invoke-Git @('rev-list', '--left-right', '--count', "HEAD...refs/remotes/origin/$branch") | Select-Object -First 1).Trim()
if ($after -notmatch '^1\s+0$') { throw "Unexpected ahead/behind after commit: $after (not pushed)" }
Invoke-Git @('push', '-q', 'origin', $branch) | Out-Null

# 5. Verify the whole mirror, exclusions, and remote
$left = @(Get-SyncPlan | Where-Object { $_.status -in 'NEW', 'CHANGED' })
$excluded = @(Get-SyncPlan | Where-Object { $_.class -ne 'public-safe' } | ForEach-Object { $_.name })
$leak = @($excluded | Where-Object { @(Get-ChildItem -LiteralPath (Join-Path $script:RepoDir '.github') -Recurse -File -Filter $_).Count -gt 0 })
$remoteSha = ((Invoke-Git @('ls-remote', '--heads', 'origin', "refs/heads/$branch") | Select-Object -First 1) -split '\s+')[0]
$head = (Invoke-Git @('rev-parse', 'HEAD') | Select-Object -First 1).Trim()
Write-Host "verify: still-differing=$($left.Count) excluded-in-repo=$($leak.Count) remote==HEAD=$($remoteSha -eq $head)"
Invoke-Git @('show', '--stat', '--oneline', 'HEAD') | Select-Object -First 12 | ForEach-Object { Write-Host $_ }
if ($left.Count -or $leak.Count -or $remoteSha -ne $head) { throw 'Post-sync verification failed.' }
Write-Host "done: https://github.com/$(($origin -replace '^.*github\.com[:/]', '' -replace '\.git$', ''))/commit/$head"
