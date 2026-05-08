# Waza Copilot Customization Evals Template

Minimal companion project for `/prompt evaluate-waza-copilot-customizations`.

このテンプレートは、Copilot customization files を `waza` で static / runtime 評価するための最小 scaffold です。

## What This Template Includes

- `.waza.yaml`
- static eval: `evals/copilot-customizations/eval.yaml`
- runtime eval: `evals/copilot-customizations/runtime-eval.yaml`
- static task scaffold: `evals/copilot-customizations/tasks/customization-static.yaml`
- runtime task writer: `evals/copilot-customizations/scripts/write-runtime-task.ps1`
- static grader: `evals/copilot-customizations/scripts/grade-copilot-customizations.ps1`
- report writer: `evals/copilot-customizations/scripts/write-copilot-customizations-report.ps1`

## What This Template Does Not Include

- project-specific target paths
- your own prompts / instructions / agents / skills
- recorded runtime tasks
- pre-generated result JSON or report files

## Quick Start

```powershell
$project = Join-Path $HOME 'waza-copilot-customization-evals'
New-Item -ItemType Directory -Force -Path $project | Out-Null

Copy-Item -LiteralPath .\templates\waza-copilot-customization-evals\* -Destination $project -Recurse -Force
Set-Location $project

waza --version
```

Then point the eval target to your User Data or workspace customizations.

```powershell
$env:WAZA_CUSTOMIZATIONS_TARGET = Join-Path $env:APPDATA 'Code\User\prompts'
waza run evals\copilot-customizations\eval.yaml --output results\customizations-eval.json --no-update-check -v
```

## Runtime Example

```powershell
$env:WAZA_CUSTOMIZATIONS_TARGET = Join-Path $env:APPDATA 'Code\User\prompts\evaluate-waza-copilot-customizations.prompt.md'

pwsh -NoProfile -ExecutionPolicy Bypass -File evals\copilot-customizations\scripts\write-runtime-task.ps1 -TargetPath $env:WAZA_CUSTOMIZATIONS_TARGET -OutputPath evals\copilot-customizations\runtime-tasks\runtime-target.yaml

waza run evals\copilot-customizations\runtime-eval.yaml --output results\runtime-customizations-eval.json --no-update-check -v
```

## Notes

- This template is PowerShell-first
- Runtime evaluation assumes `copilot-sdk` is available in your environment
- Recorded tasks are intentionally not shipped; use deterministic runtime tasks by default
- Re-run eval after renames so prompts, examples, graders, and reports stay aligned

## Related Docs

- [Waza prompt setup guide](../../docs/waza-copilot-customizations-setup.md)
- [microsoft/waza](https://github.com/microsoft/waza)