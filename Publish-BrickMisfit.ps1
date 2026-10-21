<#
.SYNOPSIS
Commits and pushes local BrickMisfit website changes to GitHub.
.DESCRIPTION
Works on Windows and macOS with PowerShell 7. Uses the script's own folder as the repository root, checks for remote changes, reviews staged files, and commits and pushes after confirmation. Stops when the remote branch is ahead or has diverged.
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

$behind = & git -C $RepoPath rev-list --count "HEAD..origin/$branch"
if ($LASTEXITCODE -ne 0) { throw 'Unable to compare local and remote branches.' }
if ([int]$behind.Trim() -gt 0) {
    Write-Host 'Remote changes were found. Publish stopped to prevent conflicts.' -ForegroundColor Red
    Write-Host "After saving any local changes, review and run: git pull --ff-only origin $branch"
    throw "Local branch is $($behind.Trim()) commit(s) behind origin/$branch."
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
