<#
.SYNOPSIS
Commits and pushes local BrickMisfit website changes to GitHub.
.DESCRIPTION
Works on Windows and macOS with PowerShell 7. Uses the script's own folder as the repository root, automatically fast-forwards a clean local branch when GitHub has newer commits, reviews staged files, and commits and pushes after confirmation. Stops safely when local changes or divergent history prevent synchronization.
#>
[CmdletBinding()]
param(
    [string]$Message,
    [switch]$Yes
)

$ErrorActionPreference = 'Stop'
$RepoPath = $PSScriptRoot

function Invoke-Git {
    param([Parameter(Mandatory)][string[]]$Arguments)
    & git -C $RepoPath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Git command failed: git $($Arguments -join ' ')"
    }
}

function Read-Choice {
    param([string]$Prompt)
    Write-Host $Prompt -ForegroundColor Yellow -NoNewline
    return (Read-Host ' ').Trim()
}

Write-Host '========== BrickMisfit Publish ==========' -ForegroundColor Green

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git was not found. Install Git and make sure it is available in PATH.'
}
if (-not $RepoPath) {
    throw 'Unable to determine the script directory.'
}

$root = & git -C $RepoPath rev-parse --show-toplevel 2>$null
if ($LASTEXITCODE -ne 0 -or -not $root) {
    throw "Save this script in the root of your cloned Git repository: $RepoPath"
}
$rootPath = [IO.Path]::GetFullPath(([string]$root).Trim()).TrimEnd([char[]]@('/', '\'))
$scriptPath = [IO.Path]::GetFullPath($RepoPath).TrimEnd([char[]]@('/', '\'))
$comparison = if ($IsWindows) { [StringComparison]::OrdinalIgnoreCase } else { [StringComparison]::Ordinal }
if (-not [string]::Equals($rootPath, $scriptPath, $comparison)) {
    throw 'Place this script in the repository root, not a subfolder.'
}

$branch = (& git -C $RepoPath branch --show-current)
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
    throw 'Could not determine the current branch. Check for a detached HEAD state.'
}
$branch = $branch.Trim()

$origin = & git -C $RepoPath remote get-url origin
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($origin)) {
    throw 'Git remote origin is missing.'
}
$origin = $origin.Trim()
Write-Host "Repository: $RepoPath"
Write-Host "Branch: $branch"
Write-Host "Remote: $origin"

Write-Host 'Fetching remote changes...' -ForegroundColor Yellow
Invoke-Git -Arguments @('fetch', 'origin', $branch)

$remoteRef = "refs/remotes/origin/$branch"
& git -C $RepoPath show-ref --verify --quiet $remoteRef
if ($LASTEXITCODE -ne 0) {
    throw "Cannot find origin/$branch after fetching. Check your remote branch configuration."
}

# Sync with GitHub
$behind = & git -C $RepoPath rev-list --count "HEAD..origin/$branch"
if ($LASTEXITCODE -ne 0) { throw 'Unable to check commits behind the remote.' }
$ahead = & git -C $RepoPath rev-list --count "origin/$branch..HEAD"
if ($LASTEXITCODE -ne 0) { throw 'Unable to check commits ahead of the remote.' }
$behindCount = [int](([string]$behind).Trim())
$aheadCount = [int](([string]$ahead).Trim())

if ($behindCount -gt 0 -and $aheadCount -gt 0) {
    throw "Local and remote branches have diverged ($aheadCount ahead, $behindCount behind). Resolve the history manually before publishing."
}

if ($behindCount -gt 0) {
    $localChanges = & git -C $RepoPath status --porcelain --untracked-files=all
    if ($LASTEXITCODE -ne 0) { throw 'Unable to check local changes before synchronization.' }
    if ($localChanges) {
        Write-Host 'GitHub has newer commits, but local changes are present.' -ForegroundColor Red
        Write-Host 'Commit, stash, or discard the local changes before synchronizing.' -ForegroundColor Yellow
        throw "Local branch is $behindCount commit(s) behind origin/$branch. Nothing was overwritten."
    }

    Write-Host "Local branch is $behindCount commit(s) behind. Fast-forwarding..." -ForegroundColor Yellow
    Invoke-Git -Arguments @('merge', '--ff-only', "origin/$branch")
    Write-Host 'Repository synchronized with GitHub.' -ForegroundColor Green
}
elseif ($aheadCount -gt 0) {
    Write-Host "Local branch is $aheadCount commit(s) ahead of GitHub." -ForegroundColor Yellow
}
else {
    Write-Host 'Local branch is up to date with GitHub.' -ForegroundColor Green
}

Write-Host 'Current changes:' -ForegroundColor Yellow
Invoke-Git -Arguments @('status', '--short')

if (-not $Yes) {
    $answer = Read-Choice 'Stage all changed files and continue? (Y/N)'
    if ($answer -notin @('Y', 'y', 'Yes', 'yes')) {
        Write-Host 'Publish cancelled.' -ForegroundColor Yellow
        return
    }
}

Invoke-Git -Arguments @('add', '--all')
$staged = & git -C $RepoPath diff --cached --name-only
if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect staged changes.' }
if (-not $staged) {
    Write-Host 'No changes to publish.' -ForegroundColor Green
    return
}

Write-Host 'Files staged for commit:' -ForegroundColor Yellow
Invoke-Git -Arguments @('diff', '--cached', '--stat')
Write-Host 'Review the staged files before publishing. Do not commit passwords, tokens, or private files.' -ForegroundColor Yellow

if ([string]::IsNullOrWhiteSpace($Message)) {
    Write-Host 'Commit message (e.g. Update BrickMisfit website)' -ForegroundColor Yellow
    $Message = Read-Host 'Message'
}
if ([string]::IsNullOrWhiteSpace($Message)) {
    throw 'Commit message cannot be empty. Staged files were retained.'
}

if (-not $Yes) {
    $answer = Read-Choice 'Commit and push these changes? (Y/N)'
    if ($answer -notin @('Y', 'y', 'Yes', 'yes')) {
        Write-Host 'Publish cancelled. Files remain staged.' -ForegroundColor Yellow
        return
    }
}

Invoke-Git -Arguments @('commit', '-m', $Message)
Write-Host 'Pushing to GitHub...' -ForegroundColor Yellow
Invoke-Git -Arguments @('push', 'origin', $branch)
Write-Host '========== Publish Complete ==========' -ForegroundColor Green
