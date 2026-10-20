<#
.SYNOPSIS
Commits and pushes local BrickMisfit website changes to GitHub.
.DESCRIPTION
Validates the repository and branch, fetches remote changes, stages and reviews changes, then commits and pushes only after confirmation. Stops if the remote branch is ahead to avoid overwriting work.
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

Write-Host '========== BrickMisfit Publish ==========' -ForegroundColor Green

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git was not found. Install Git for Windows first.'
}

$root = (& git -C $RepoPath rev-parse --show-toplevel 2>$null)
if ($LASTEXITCODE -ne 0 -or -not $root) {
    throw "This script must be saved in the root of the cloned Git repository: $RepoPath"
}
if ([IO.Path]::GetFullPath($root).TrimEnd('\','/') -ne [IO.Path]::GetFullPath($RepoPath).TrimEnd('\','/')) {
    throw 'Place this script in the repository root, not a subfolder.'
}

$branch = (& git -C $RepoPath branch --show-current).Trim()
if ($LASTEXITCODE -ne 0 -or -not $branch) {
    throw 'Could not determine the current branch. Check that you are not in detached HEAD state.'
}

$origin = (& git -C $RepoPath remote get-url origin).Trim()
if ($LASTEXITCODE -ne 0 -or -not $origin) {
    throw 'Git remote origin is missing.'
}
Write-Host "Repository: $RepoPath"
Write-Host "Branch: $branch"
Write-Host "Remote: $origin"

Write-Host 'Fetching remote changes...' -ForegroundColor Yellow
Invoke-Git -Arguments @('fetch', 'origin', $branch)

$behind = (& git -C $RepoPath rev-list --count "HEAD..origin/$branch").Trim()
if ($LASTEXITCODE -ne 0) { throw 'Unable to compare local and remote branches.' }
if ([int]$behind -gt 0) {
    Write-Host 'Remote changes were found. Publish stopped to prevent conflicts.' -ForegroundColor Red
    Write-Host "Review changes and run: git pull --rebase origin $branch"
    throw "Local branch is $behind commit(s) behind origin/$branch."
}

Write-Host 'Current changes:' -ForegroundColor Yellow
Invoke-Git -Arguments @('status', '--short')

if (-not $Yes) {
    $answer = Read-Host 'Stage all changed files and continue? (Y/N)'
    if ($answer -notin @('Y', 'y', 'Yes', 'yes')) {
        Write-Host 'Publish cancelled.' -ForegroundColor Yellow
        return
    }
}

Invoke-Git -Arguments @('add', '--all')
$staged = (& git -C $RepoPath diff --cached --name-only)
if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect staged changes.' }
if (-not $staged) {
    Write-Host 'No changes to publish.' -ForegroundColor Green
    return
}

Write-Host 'Files staged for commit:' -ForegroundColor Yellow
Invoke-Git -Arguments @('diff', '--cached', '--stat')

if (-not $Message) {
    $Message = Read-Host 'Commit message (e.g. Add Brick Resources page)'
}
if ([string]::IsNullOrWhiteSpace($Message)) {
    throw 'Commit message cannot be empty. Staged files were retained.'
}

if (-not $Yes) {
    $answer = Read-Host 'Commit and push these changes? (Y/N)'
    if ($answer -notin @('Y', 'y', 'Yes', 'yes')) {
        Write-Host 'Publish cancelled. Files remain staged.' -ForegroundColor Yellow
        return
    }
}

Invoke-Git -Arguments @('commit', '-m', $Message)
Write-Host 'Pushing to GitHub...' -ForegroundColor Yellow
Invoke-Git -Arguments @('push', 'origin', $branch)
Write-Host '========== Publish Complete ==========' -ForegroundColor Green
