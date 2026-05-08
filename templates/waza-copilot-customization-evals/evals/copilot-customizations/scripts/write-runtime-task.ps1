param(
    [Parameter(Mandatory = $true)]
    [string]$TargetPath,

    [string]$OutputPath = 'evals/copilot-customizations/runtime-tasks/runtime-target.yaml',
    [string]$RuntimePrompt,
    [string]$TaskId = 'runtime-target-001',
    [string]$TaskName = 'Copilot Customization Runtime Review'
)

$ErrorActionPreference = 'Stop'

$resolvedTarget = (Resolve-Path -LiteralPath $TargetPath).Path
$targetName = Split-Path -Leaf $resolvedTarget

if ([string]::IsNullOrWhiteSpace($RuntimePrompt)) {
    $RuntimePrompt = @"
Review the Copilot customization target at $resolvedTarget.
Read this exact target directly before answering.
Do not switch to a different file such as ~/.copilot/copilot-instructions.md unless the target itself points there.
Return exactly these section headings in English:

Purpose:
- one to three concise bullets

Guardrails:
- one to three concise bullets

Usage:
- one to three concise bullets

Requirements:
- Mention $targetName in the Purpose section.
- Keep the body concise.
- Do not ask clarifying questions unless the target truly cannot be read.
"@
}

$yaml = @"
# yaml-language-server: `$schema=https://raw.githubusercontent.com/microsoft/waza/main/schemas/task.schema.json
id: $TaskId
name: $TaskName
description: |
  Runtime smoke review for a Copilot customization target using copilot-sdk.
inputs:
  prompt: |
$(($RuntimePrompt -split "`r?`n") | ForEach-Object { "    $_" } | Out-String)
graders:
  - name: required-structure
    type: text
    config:
      contains_cs:
        - "Purpose:"
        - "Guardrails:"
        - "Usage:"
        - "$targetName"
  - name: runtime-tool-usage
    type: tool_calls
    config:
      required_tools:
        - "view"
      min_calls: 1
"@

$outputDir = Split-Path -Parent $OutputPath
if (-not [string]::IsNullOrWhiteSpace($outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
}

Set-Content -LiteralPath $OutputPath -Value $yaml.Trim() -Encoding UTF8
Write-Host "PASS: runtime task written to $OutputPath"