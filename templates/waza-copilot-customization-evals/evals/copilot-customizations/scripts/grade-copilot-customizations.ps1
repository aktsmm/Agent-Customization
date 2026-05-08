param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('metadata', 'agent-structure', 'token-budget')]
    [string]$Mode,

    [string]$TargetPath,

    [int]$MaxFileTokens = 5000,
    [int]$MaxTotalTokens = 60000
)

$ErrorActionPreference = 'Stop'

function Resolve-TargetPath {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        $Path = $env:WAZA_CUSTOMIZATIONS_TARGET
    }

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return Join-Path $env:APPDATA 'Code\User\prompts'
    }

    $expanded = [Environment]::ExpandEnvironmentVariables($Path)
    if ($expanded -like '~*') {
        $expanded = Join-Path $HOME $expanded.Substring(1).TrimStart('\\', '/')
    }

    return (Resolve-Path -LiteralPath $expanded).Path
}

$customizationsRoot = Resolve-TargetPath $TargetPath
if (-not (Test-Path $customizationsRoot)) {
    Write-Host "FAIL: target path not found: $customizationsRoot"
    exit 1
}

function Get-CustomizationKind {
    param([string]$Name)
    if ($Name -like '*.agent.md') { return 'agent' }
    if ($Name -like '*.prompt.md') { return 'prompt' }
    if ($Name -like '*.instructions.md') { return 'instructions' }
    if ($Name -eq 'SKILL.md') { return 'skill' }
    return 'other'
}

function Get-FrontmatterText {
    param([string]$Path)
    $content = Get-Content -Raw -Encoding UTF8 $Path
    $match = [regex]::Match($content, '(?s)^---\r?\n(.*?)\r?\n---')
    if (-not $match.Success) { return $null }
    return $match.Groups[1].Value
}

function Convert-FrontmatterToMap {
    param([string]$Frontmatter)

    $map = @{}
    if ([string]::IsNullOrWhiteSpace($Frontmatter)) { return $map }

    $lines = $Frontmatter -split "`r?`n"
    for ($index = 0; $index -lt $lines.Count; $index++) {
        $line = $lines[$index]
        if ($line -notmatch '^([A-Za-z0-9_-]+):\s*(.*)$') { continue }

        $key = $Matches[1]
        $value = $Matches[2].Trim()

        if ($value -eq '|' -or $value -eq '>') {
            $parts = New-Object System.Collections.Generic.List[string]
            $next = $index + 1
            while ($next -lt $lines.Count -and $lines[$next] -notmatch '^[A-Za-z0-9_-]+:\s*') {
                $parts.Add($lines[$next].Trim())
                $next++
            }
            $value = ($parts -join ' ').Trim()
            $index = $next - 1
        }
        elseif ($value -eq '') {
            $parts = New-Object System.Collections.Generic.List[string]
            $next = $index + 1
            while ($next -lt $lines.Count -and $lines[$next] -match '^\s+-\s+(.+)$') {
                $parts.Add($Matches[1].Trim())
                $next++
            }
            if ($parts.Count -gt 0) {
                $value = ($parts -join ', ')
                $index = $next - 1
            }
        }

        $value = $value.Trim('''').Trim('"')
        $map[$key] = $value
    }
    return $map
}

function Get-CustomizationFiles {
    $item = Get-Item -LiteralPath $customizationsRoot
    $candidates = if ($item.PSIsContainer) {
        Get-ChildItem $customizationsRoot -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object {
                $_.FullName -notmatch '\\(\.git|node_modules|\.venv|venv|dist|build|out|coverage)\\' -and
                ($_.Name -like '*.agent.md' -or $_.Name -like '*.prompt.md' -or $_.Name -like '*.instructions.md' -or $_.Name -eq 'SKILL.md')
            }
    }
    else {
        @($item) | Where-Object { $_.Name -like '*.agent.md' -or $_.Name -like '*.prompt.md' -or $_.Name -like '*.instructions.md' -or $_.Name -eq 'SKILL.md' }
    }

    $candidates | Sort-Object Name
}

$files = @(Get-CustomizationFiles)
$issues = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

if ($files.Count -eq 0) {
    Write-Host "FAIL: no customization files found under target: $customizationsRoot"
    exit 1
}

switch ($Mode) {
    'metadata' {
        foreach ($file in $files) {
            $kind = Get-CustomizationKind $file.Name
            $frontmatter = Get-FrontmatterText $file.FullName
            if ($null -eq $frontmatter) {
                $issues.Add("$($file.Name): missing YAML frontmatter")
                continue
            }

            $metadata = Convert-FrontmatterToMap $frontmatter
            if (-not $metadata.ContainsKey('description') -or [string]::IsNullOrWhiteSpace($metadata['description'])) {
                $issues.Add("$($file.Name): missing description")
            }

            if ($kind -eq 'agent' -and (-not $metadata.ContainsKey('name') -or [string]::IsNullOrWhiteSpace($metadata['name']))) {
                $issues.Add("$($file.Name): agent missing name")
            }

            if ($kind -eq 'skill' -and (-not $metadata.ContainsKey('name') -or [string]::IsNullOrWhiteSpace($metadata['name']))) {
                $issues.Add("$($file.FullName): SKILL.md missing name")
            }

            if ($kind -eq 'instructions' -and (-not $metadata.ContainsKey('applyTo'))) {
                $warnings.Add("$($file.Name): instruction has no applyTo pattern")
            }
        }

        Write-Host "Checked $($files.Count) customization files under target: $customizationsRoot"
        Write-Host "Warnings: $($warnings.Count)"
        $warnings | ForEach-Object { Write-Host "WARN: $_" }
    }

    'agent-structure' {
        $agentFiles = @($files | Where-Object { $_.Name -like '*.agent.md' })
        foreach ($file in $agentFiles) {
            $content = Get-Content -Raw -Encoding UTF8 $file.FullName
            $frontmatter = Get-FrontmatterText $file.FullName
            if ($null -eq $frontmatter) {
                $issues.Add("$($file.Name): missing YAML frontmatter")
                continue
            }

            $metadata = Convert-FrontmatterToMap $frontmatter
            foreach ($required in @('name', 'description')) {
                if (-not $metadata.ContainsKey($required) -or [string]::IsNullOrWhiteSpace($metadata[$required])) {
                    $issues.Add("$($file.Name): missing $required")
                }
            }

            if (-not $metadata.ContainsKey('tools')) {
                $warnings.Add("$($file.Name): no explicit tools list")
            }

            if ($metadata.ContainsKey('description') -and $metadata['description'].Length -lt 80) {
                $warnings.Add("$($file.Name): description is short ($($metadata['description'].Length) chars)")
            }

            $sectionCount = ([regex]::Matches($content, '(?m)^##\s+')).Count
            if ($sectionCount -lt 3) {
                $warnings.Add("$($file.Name): only $sectionCount second-level sections")
            }

            if ($content -notmatch '(?i)DO NOT|MUST NOT|禁止|しない') {
                $warnings.Add("$($file.Name): no explicit negative constraints detected")
            }
        }

        Write-Host "Checked $($agentFiles.Count) agent files."
        Write-Host "Warnings: $($warnings.Count)"
        $warnings | ForEach-Object { Write-Host "WARN: $_" }
    }

    'token-budget' {
        $tokenArgs = @('tokens', 'count') + @($files | ForEach-Object { $_.FullName }) + @('--format', 'json', '--no-update-check')
        $json = & waza @tokenArgs | ConvertFrom-Json
        Write-Host "Token total: $($json.totalTokens) across $($json.totalFiles) files."

        if ($json.totalTokens -gt $MaxTotalTokens) {
            $issues.Add("total tokens $($json.totalTokens) exceed budget $MaxTotalTokens")
        }

        $oversized = @()
        foreach ($property in $json.files.PSObject.Properties) {
            $entry = $property.Value
            if ($entry.tokens -gt $MaxFileTokens) {
                $oversized += [pscustomobject]@{ Path = $property.Name; Tokens = [int]$entry.tokens }
            }
        }

        $oversized = @($oversized | Sort-Object Tokens -Descending)
        foreach ($item in $oversized) {
            $issues.Add("$($item.Path): $($item.Tokens) tokens exceed file budget $MaxFileTokens")
        }

        Write-Host "Oversized files: $($oversized.Count)"
        $oversized | ForEach-Object { Write-Host "OVER: $($_.Tokens) $($_.Path)" }
    }
}

if ($issues.Count -gt 0) {
    Write-Host "FAIL: $($issues.Count) issue(s) found."
    $issues | ForEach-Object { Write-Host "ISSUE: $_" }
    exit 1
}

Write-Host "PASS: $Mode gate passed."
exit 0