param(
    [Parameter(Mandatory = $true)]
    [string]$ResultJson,

    [Parameter(Mandatory = $true)]
    [string]$TargetPath,

    [string]$OutputPath,
    [string]$Action = 'run',
    [string]$EvalProject = '~/waza-copilot-customization-evals',
    [string]$StaticEvalPath = 'evals/copilot-customizations/eval.yaml',
    [string]$RuntimeEvalPath = 'evals/copilot-customizations/runtime-eval.yaml',
    [string]$Notes = ''
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $ResultJson)) {
    Write-Host "FAIL: result JSON not found: $ResultJson"
    exit 1
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $date = Get-Date -Format 'yyyy-MM-dd'
    $OutputPath = Join-Path 'reports' "$date-copilot-customizations-waza-report.md"
}

$outputDir = Split-Path -Parent $OutputPath
if (-not [string]::IsNullOrWhiteSpace($outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
}

$result = Get-Content -Raw -Encoding UTF8 $ResultJson | ConvertFrom-Json
$summary = $result.summary
$runEvalPath = if ($Action -eq 'runtime' -or $ResultJson -like '*runtime*') { $RuntimeEvalPath } else { $StaticEvalPath }
$taskResult = $null
if ($result.tasks -and $result.tasks.Count -gt 0) {
    $taskResult = $result.tasks[0]
}

$gateLines = New-Object System.Collections.Generic.List[string]
$findingLines = New-Object System.Collections.Generic.List[string]
$warningLines = New-Object System.Collections.Generic.List[string]

if ($taskResult -and $taskResult.runs -and $taskResult.runs.Count -gt 0) {
    $run = $taskResult.runs[0]
    if ($run.validations) {
        $validationNames = @($run.validations.PSObject.Properties.Name)
        foreach ($graderName in $validationNames) {
            $grader = $run.validations.PSObject.Properties[$graderName].Value
            $status = if ($grader.passed) { 'Pass' } else { 'Fail' }
            $feedback = if ([string]::IsNullOrWhiteSpace($grader.feedback)) { '-' } else { ($grader.feedback -replace "`r?`n", ' ') }
            $gateLines.Add("| ``$graderName`` | $status | $feedback |")

            if (-not $grader.passed) {
                $findingLines.Add("- ``$graderName``: $feedback")
            }

            $feedbackLines = @($grader.feedback -split "`r?`n")
            foreach ($line in $feedbackLines) {
                if ($line -match '^WARN:\s+(.+)$') {
                    $warningLines.Add("- ``$graderName``: $($Matches[1])")
                }
                elseif ($line -match '^ISSUE:\s+(.+)$') {
                    $findingLines.Add("- ``$graderName``: $($Matches[1])")
                }
                elseif ($line -match '^OVER:\s+(.+)$') {
                    $findingLines.Add("- ``$graderName``: $($Matches[1])")
                }
            }
        }
    }
}

if ($findingLines.Count -eq 0) {
    $findingLines.Add('- なし')
}

if ($warningLines.Count -eq 0) {
    $warningLines.Add('- 追加警告は結果 JSON から抽出されません。必要なら個別 gate を再実行して詳細を取得する。')
}

$report = New-Object System.Collections.Generic.List[string]
$report.Add('# Copilot Customizations Waza Report')
$report.Add('')
$report.Add("- Date: $(Get-Date -Format 'yyyy-MM-dd')")
$report.Add('- Model: GitHub Copilot')
$report.Add("- Action: $Action")
$report.Add("- Evaluated source: ``$TargetPath``")
$report.Add("- Evaluation project: ``$EvalProject``")
$report.Add("- Static eval: ``$StaticEvalPath``")
$report.Add("- Runtime eval: ``$RuntimeEvalPath``")
$report.Add("- Result JSON: ``$ResultJson``")
$report.Add('')
$report.Add('## Summary')
$report.Add('')
$report.Add("- Total tests: $($summary.total_tests)")
$report.Add("- Succeeded: $($summary.succeeded)")
$report.Add("- Failed: $($summary.failed)")
$report.Add("- Errors: $($summary.errors)")
$report.Add("- Success rate: $([math]::Round($summary.success_rate * 100, 1))%")
$report.Add("- Aggregate score: $([math]::Round($summary.aggregate_score, 2))")
$report.Add('')
$report.Add('## Gates')
$report.Add('')
$report.Add('| Gate | Result | Notes |')
$report.Add('| --- | --- | --- |')
foreach ($line in $gateLines) {
    $report.Add($line)
}
$report.Add('')
$report.Add('## Findings')
$report.Add('')
foreach ($line in $findingLines) {
    $report.Add($line)
}
$report.Add('')
$report.Add('## Warnings')
$report.Add('')
foreach ($line in $warningLines) {
    $report.Add($line)
}
$report.Add('')
$report.Add('## Commands')
$report.Add('')
$report.Add('```powershell')
$report.Add("Set-Location $EvalProject")
$report.Add("`$env:WAZA_CUSTOMIZATIONS_TARGET = '$TargetPath'")
$report.Add("waza run $runEvalPath --output $ResultJson --no-update-check -v")
$report.Add('```')
$report.Add('')
$report.Add('## Next Fix Candidates')
$report.Add('- Review failed gates and rerun individual gate commands for detailed findings.')
$report.Add('- Tighten token budgets or split large prompt files when token gate fails.')
$report.Add('- Add or repair YAML frontmatter when metadata gate fails.')
$report.Add('- Expand agent descriptions and constraints when agent structure warnings appear.')

if (-not [string]::IsNullOrWhiteSpace($Notes)) {
    $report.Add('')
    $report.Add('## Notes')
    $report.Add($Notes)
}

$reportText = $report -join "`r`n"
Set-Content -LiteralPath $OutputPath -Value $reportText -Encoding UTF8
Write-Host "PASS: report written to $OutputPath"