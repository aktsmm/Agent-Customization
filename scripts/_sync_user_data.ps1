$src = 'C:\Users\vainf\AppData\Roaming\Code\User\prompts'
$repo = 'D:\03_github\00_VSC_tools\.ghc_template\.github'

Write-Host '=== instructions/core ===' -ForegroundColor Cyan
'autonomy','communication','copilot-loading','naming-conventions','prompts-metadata','security','terminal','vscode-environment' | ForEach-Object {
    Copy-Item "$src\$_.instructions.md" "$repo\instructions\core\$_.instructions.md" -Force
    Write-Host "  synced: $_.instructions.md"
}

Write-Host '=== instructions/dev ===' -ForegroundColor Cyan
'nodejs','python','git-publish-policy' | ForEach-Object {
    Copy-Item "$src\$_.instructions.md" "$repo\instructions\dev\$_.instructions.md" -Force
    Write-Host "  synced: $_.instructions.md"
}
Copy-Item "$src\git-operations.instructions.md" "$repo\instructions\dev\git-operations.instructions.md" -Force
Remove-Item "$repo\instructions\dev\git.instructions.md" -Force -ErrorAction SilentlyContinue
Write-Host '  renamed: git.instructions.md -> git-operations.instructions.md'

Write-Host '=== instructions/integrations ===' -ForegroundColor Cyan
'microsoft-docs','web-search' | ForEach-Object {
    Copy-Item "$src\$_.instructions.md" "$repo\instructions\integrations\$_.instructions.md" -Force
    Write-Host "  synced: $_.instructions.md"
}
Copy-Item "$src\troubleshoot-local-network.instructions.md" "$repo\instructions\integrations\troubleshoot-local-network.instructions.md" -Force
Remove-Item "$repo\instructions\integrations\local-network-troubleshoot.instructions.md" -Force -ErrorAction SilentlyContinue
Write-Host '  renamed: local-network-troubleshoot -> troubleshoot-local-network'

Write-Host '=== delete obsolete instructions ===' -ForegroundColor Yellow
'core\learnings','core\session-metadata','core\user-data-default','dev\pptx-editing','integrations\edge-cdp' | ForEach-Object {
    Remove-Item "$repo\instructions\$_.instructions.md" -Force -ErrorAction SilentlyContinue
    Write-Host "  deleted: $_.instructions.md"
}

Write-Host '=== prompts ===' -ForegroundColor Cyan
'evaluate-waza-copilot-customizations','export-copilot-session-dialogue','export-knowledge','export-session-log',
'git-commit-push','git-commit','git-pull','refactor-context','refine-product-100',
'retro-user','retro-workspace','review-agents-and-instructions','wrap-up-work','write-tests',
'tweet-generate-x','tweet-x-csa-microsoft','sync-public-skills','review-security-structure-map' | ForEach-Object {
    Copy-Item "$src\$_.prompt.md" "$repo\prompts\$_.prompt.md" -Force
    Write-Host "  synced: $_.prompt.md"
}
'convert-to-tweet','export-sync-to-public-skills','security-structure-map-review','generate-x-tweet-growth-post' | ForEach-Object {
    Remove-Item "$repo\prompts\$_.prompt.md" -Force -ErrorAction SilentlyContinue
    Write-Host "  deleted: $_.prompt.md"
}

Write-Host '=== agents ===' -ForegroundColor Cyan
'DeepResearch','enhanced-plan','fact-checker','ReportWriter','workflow-designer' | ForEach-Object {
    Copy-Item "$src\$_.agent.md" "$repo\agents\$_.agent.md" -Force
    Write-Host "  synced: $_.agent.md"
}
Remove-Item "$repo\agents\sync-to-global.agent.md" -Force -ErrorAction SilentlyContinue
Write-Host '  deleted: sync-to-global.agent.md'

Write-Host '=== git ===' -ForegroundColor Cyan
Set-Location 'D:\03_github\00_VSC_tools\.ghc_template'
git add .
git status --short
git commit -m "chore(sync): mirror user customizations - rename obsolete files, sync autonomy/terminal updates"
git push

Write-Host '=== complete ===' -ForegroundColor Green
