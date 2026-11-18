#Requires -Module Pester

$script:Script = (Resolve-Path (Join-Path $PSScriptRoot '..\..\scripts\Sync-UserCustomizations.ps1')).Path

function New-SyncFixture {
    param([string]$Root)
    $remote = Join-Path $Root 'remote.git'
    $repo = Join-Path $Root 'repo'
    $source = Join-Path $Root 'source'
    New-Item -ItemType Directory -Path $Root, $source -Force | Out-Null
    git init -q --bare $remote
    git init -q $repo
    git -C $repo config user.email 'fixture@example.invalid'
    git -C $repo config user.name 'Fixture'
    git -C $repo branch -M master
    foreach ($d in '.github\prompts', '.github\instructions\core') { New-Item -ItemType Directory -Path (Join-Path $repo $d) -Force | Out-Null }
    $head = "---`ndescription: fixture`n---`n<!-- syncToGlobal: true -->`n"
    [IO.File]::WriteAllText((Join-Path $repo '.github\prompts\alpha.prompt.md'), "$head# Alpha`nSelf-Contained rule.`n")
    [IO.File]::WriteAllText((Join-Path $repo '.github\instructions\core\beta.instructions.md'), "$head# Beta`nsame`n")
    '# ignored' | Set-Content -LiteralPath (Join-Path $repo '.github\.sync-ignore')
    "skipped.prompt.md`n" | Add-Content -LiteralPath (Join-Path $repo '.github\.sync-ignore')
    git -C $repo add . | Out-Null
    git -C $repo commit -q -m 'test: initial'
    git -C $repo remote add origin $remote
    git -C $repo push -q -u origin master 2>&1 | Out-Null
    [IO.File]::WriteAllText((Join-Path $source 'alpha.prompt.md'), "$head# Alpha`nSelf-Contained rule.`n")
    [IO.File]::WriteAllText((Join-Path $source 'beta.instructions.md'), "$head# Beta`nsame`n")
    [IO.File]::WriteAllText((Join-Path $source 'private.prompt.md'), "---`n---`n<!-- syncToGlobal: false -->`n# Private`n")
    [IO.File]::WriteAllText((Join-Path $source 'skipped.prompt.md'), "$head# Ignored by sync-ignore`n")
    [IO.File]::WriteAllText((Join-Path $source 'sync-user-customizations-to-github.prompt.md'), "$head# self`n")
    [pscustomobject]@{ Repo = $repo; Source = $source; Remote = $remote }
}

function Invoke-Sync {
    param($Fixture, [switch]$Apply)
    $pwshArgs = @('-NoProfile', '-File', $script:Script, '-RepoDir', $Fixture.Repo, '-Source', $Fixture.Source, '-ExpectedGitHubRepo', 'remote.git')
    if ($Apply) { $pwshArgs += '-Apply' }
    $out = & pwsh @pwshArgs 2>&1 | ForEach-Object { $_.ToString() }
    [pscustomobject]@{ Exit = $LASTEXITCODE; Text = ($out -join "`n") }
}

Describe 'Sync-UserCustomizations' {
    BeforeEach { $script:Fx = New-SyncFixture -Root (Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))) }

    It 'reports nothing to do when mirrors match and never publishes excluded files' {
        $r = Invoke-Sync $script:Fx
        $r.Exit | Should Be 0
        $r.Text | Should Match 'same=2'
        $r.Text | Should Match 'excluded=3'
        $r.Text | Should Match 'audit: PASS \(0 candidate'
    }

    It 'maps reference instructions to existing mirrors and excludes local-only notes' {
        $refs = Join-Path (Split-Path $script:Fx.Source -Parent) 'references'
        New-Item -ItemType Directory -Path $refs | Out-Null
        $head = "---`ndescription: fixture`n---`n<!-- syncToGlobal: true -->`n"
        [IO.File]::WriteAllText((Join-Path $refs 'beta.instructions.md'), "$head# Beta`nsame`n")
        [IO.File]::WriteAllText((Join-Path $refs 'local.instructions.md'), "---`n---`n<!-- syncToGlobal: false -->`n# Local`n")
        $referenceFixture = [pscustomobject]@{ Repo = $script:Fx.Repo; Source = $refs; Remote = $script:Fx.Remote }

        $r = Invoke-Sync $referenceFixture
        $r.Exit | Should Be 0
        $r.Text | Should Match 'same=1'
        $r.Text | Should Match 'excluded=1'
    }

    It 'detects a case-only difference' {
        $p = Join-Path $script:Fx.Source 'alpha.prompt.md'
        [IO.File]::WriteAllText($p, ([IO.File]::ReadAllText($p) -replace 'Self-Contained', 'Self-contained'))
        (Invoke-Sync $script:Fx).Text | Should Match 'CHANGED\s+alpha\.prompt\.md'
    }

    It 'ignores EOL-only differences' {
        $p = Join-Path $script:Fx.Source 'alpha.prompt.md'
        [IO.File]::WriteAllText($p, ([IO.File]::ReadAllText($p) -replace "`n", "`r`n"))
        (Invoke-Sync $script:Fx).Text | Should Match 'same=2'
    }

    It 'does not write anything in report mode' {
        $p = Join-Path $script:Fx.Source 'alpha.prompt.md'
        [IO.File]::WriteAllText($p, ([IO.File]::ReadAllText($p) + "added`n"))
        $before = git -C $script:Fx.Repo rev-parse HEAD
        Invoke-Sync $script:Fx | Out-Null
        (git -C $script:Fx.Repo rev-parse HEAD) | Should Be $before
        @(git -C $script:Fx.Repo status --porcelain).Count | Should Be 0
    }

    It 'stops before writing when the audit finds a secret-shaped value' {
        $p = Join-Path $script:Fx.Source 'alpha.prompt.md'
        [IO.File]::WriteAllText($p, ([IO.File]::ReadAllText($p) + "password = Abcdefghij1234567`n"))
        $before = git -C $script:Fx.Repo rev-parse HEAD
        $r = Invoke-Sync $script:Fx -Apply
        $r.Exit | Should Not Be 0
        $r.Text | Should Match 'Audit found'
        (git -C $script:Fx.Repo rev-parse HEAD) | Should Be $before
        @(git -C $script:Fx.Repo status --porcelain).Count | Should Be 0
    }

    It 'refuses to commit when the repo has existing uncommitted changes' {
        $p = Join-Path $script:Fx.Source 'alpha.prompt.md'
        [IO.File]::WriteAllText($p, ([IO.File]::ReadAllText($p) + "added`n"))
        'user work' | Set-Content -LiteralPath (Join-Path $script:Fx.Repo 'notes.txt')
        $before = git -C $script:Fx.Repo rev-parse HEAD
        $r = Invoke-Sync $script:Fx -Apply
        $r.Exit | Should Not Be 0
        $r.Text | Should Match 'existing uncommitted'
        (git -C $script:Fx.Repo rev-parse HEAD) | Should Be $before
    }

    It 'mirrors only changed public-safe files, commits and pushes' {
        $p = Join-Path $script:Fx.Source 'alpha.prompt.md'
        [IO.File]::WriteAllText($p, ([IO.File]::ReadAllText($p) + "added line`n"))
        $r = Invoke-Sync $script:Fx -Apply
        $r.Exit | Should Be 0
        $r.Text | Should Match 'remote==HEAD=True'
        (git -C $script:Fx.Repo diff --name-only 'HEAD^..HEAD') | Should Be '.github/prompts/alpha.prompt.md'
        $remoteSha = ((git -C $script:Fx.Repo ls-remote --heads origin refs/heads/master) -split '\s+')[0]
        $remoteSha | Should Be (git -C $script:Fx.Repo rev-parse HEAD)
        Test-Path -LiteralPath (Join-Path $script:Fx.Repo '.github\prompts\private.prompt.md') | Should Be $false
        Test-Path -LiteralPath (Join-Path $script:Fx.Repo '.github\prompts\skipped.prompt.md') | Should Be $false
    }

    It 'marks a new instructions file with no existing category as needs-review and writes nothing' {
        $head = "---`n---`n<!-- syncToGlobal: true -->`n"
        [IO.File]::WriteAllText((Join-Path $script:Fx.Source 'gamma.instructions.md'), "$head# Gamma`n")
        $before = git -C $script:Fx.Repo rev-parse HEAD
        $r = Invoke-Sync $script:Fx -Apply
        $r.Text | Should Match 'needs-review: gamma\.instructions\.md'
        (git -C $script:Fx.Repo rev-parse HEAD) | Should Be $before
    }

    It 'reports mirror files absent from the source without deleting them' {
        Remove-Item -LiteralPath (Join-Path $script:Fx.Source 'alpha.prompt.md')
        $r = Invoke-Sync $script:Fx
        $r.Text | Should Match 'deletion candidates \(report only\): 1'
        Test-Path -LiteralPath (Join-Path $script:Fx.Repo '.github\prompts\alpha.prompt.md') | Should Be $true
    }

    It 'treats files from every source as present, so agents and references are not deletion candidates' {
        $base = Split-Path $script:Fx.Source -Parent
        $agents = Join-Path $base 'agents'
        New-Item -ItemType Directory -Path $agents | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $script:Fx.Repo '.github\agents') -Force | Out-Null
        $head = "---`ndescription: fixture`n---`n<!-- syncToGlobal: true -->`n"
        [IO.File]::WriteAllText((Join-Path $script:Fx.Repo '.github\agents\role.agent.md'), "$head# Role`n")
        [IO.File]::WriteAllText((Join-Path $agents 'role.agent.md'), "$head# Role`n")
        git -C $script:Fx.Repo add . | Out-Null
        git -C $script:Fx.Repo commit -q -m 'test: add agent'
        git -C $script:Fx.Repo push -q origin master 2>&1 | Out-Null

        $sources = "@('$($script:Fx.Source)','$agents')"
        $out = & pwsh -NoProfile -Command "& '$script:Script' -RepoDir '$($script:Fx.Repo)' -Source $sources -ExpectedGitHubRepo 'remote.git'" 2>&1 | ForEach-Object { $_.ToString() }
        $LASTEXITCODE | Should Be 0
        $text = $out -join "`n"
        $text | Should Match 'same=3'
        $text | Should Match 'deletion candidates \(report only\): 0'

        $single = Invoke-Sync $script:Fx
        $single.Text | Should Match 'deletion candidates \(report only\): 1'
    }

    It 'stops when the same file name exists in two sources' {
        $other = Join-Path (Split-Path $script:Fx.Source -Parent) 'references'
        New-Item -ItemType Directory -Path $other | Out-Null
        Copy-Item -LiteralPath (Join-Path $script:Fx.Source 'beta.instructions.md') -Destination $other
        $sources = "@('$($script:Fx.Source)','$other')"
        $out = & pwsh -NoProfile -Command "& '$script:Script' -RepoDir '$($script:Fx.Repo)' -Source $sources -ExpectedGitHubRepo 'remote.git'" 2>&1 | ForEach-Object { $_.ToString() }
        $LASTEXITCODE | Should Not Be 0
        ($out -join "`n") | Should Match 'Duplicate file name across sources: beta\.instructions\.md'
    }

    It 'uses the standard ~/.copilot folders when -Source is omitted and skips missing ones' {
        $fakeHome = Join-Path (Split-Path $script:Fx.Source -Parent) 'home'
        New-Item -ItemType Directory -Path (Join-Path $fakeHome '.copilot') | Out-Null
        Copy-Item -LiteralPath $script:Fx.Source -Destination (Join-Path $fakeHome '.copilot\instructions') -Recurse
        $oldProfile = $env:USERPROFILE; $oldHome = $env:HOME
        try {
            $env:USERPROFILE = $fakeHome; $env:HOME = $fakeHome
            $out = & pwsh -NoProfile -File $script:Script -RepoDir $script:Fx.Repo -ExpectedGitHubRepo 'remote.git' 2>&1 | ForEach-Object { $_.ToString() }
        }
        finally { $env:USERPROFILE = $oldProfile; $env:HOME = $oldHome }
        $LASTEXITCODE | Should Be 0
        $text = $out -join "`n"
        $text | Should Match 'sources: .*instructions'
        $text | Should Match 'same=2'
    }

    It 'stops when origin does not match the expected GitHub repo' {
        $out = & pwsh -NoProfile -File $script:Script -RepoDir $script:Fx.Repo -Source $script:Fx.Source -ExpectedGitHubRepo 'someone/else' 2>&1 | ForEach-Object { $_.ToString() }
        $LASTEXITCODE | Should Not Be 0
        ($out -join "`n") | Should Match 'does not match'
    }
}
