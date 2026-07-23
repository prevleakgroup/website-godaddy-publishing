#Requires -Version 5.1
<#
.SYNOPSIS
    One-click publisher for the GoDaddy cPanel GitHub Actions workflows.
.DESCRIPTION
    Commits the latest changes, sets the required SFTP/cPanel secrets, and
    triggers all deploy workflows on GitHub.
.NOTES
    Run this script from the repository root (C:\Users\Admin\repos\assessment).
    You must be authenticated with the GitHub CLI (`gh auth login`) before running.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$ghExe = "C:\Program Files\GitHub CLI\gh.exe"
$gitExe = "C:\Program Files\Git\cmd\git.exe"

# Step 1: go to project folder
$projectPath = "C:\Users\Admin\repos\assessment"
Set-Location -Path $projectPath
Write-Host "Step 1: Changed directory to $projectPath" -ForegroundColor Cyan

# Step 2: confirm GitHub login
Write-Host "`nStep 2: Verifying GitHub CLI authentication..." -ForegroundColor Cyan
& $ghExe auth status

# Step 3: detect repo name
Write-Host "`nStep 3: Detecting repository name..." -ForegroundColor Cyan
$REPO = & $ghExe repo view --json nameWithOwner -q .nameWithOwner
Write-Host "Repository: $REPO"

# Step 4: commit and push latest changes
Write-Host "`nStep 4: Committing and pushing latest changes..." -ForegroundColor Cyan
& $gitExe add -A
& $gitExe commit -m "Publish website, SEO, and cPanel workflows"
& $gitExe push

# Step 5: set required secrets for website deploy
Write-Host "`nStep 5: Setting website deploy secrets..." -ForegroundColor Cyan
& $ghExe secret set CPANEL_SFTP_HOST --repo $REPO
& $ghExe secret set CPANEL_SFTP_PORT --repo $REPO
& $ghExe secret set CPANEL_SFTP_USERNAME --repo $REPO
& $ghExe secret set CPANEL_SFTP_PASSWORD --repo $REPO
& $ghExe secret set CPANEL_SFTP_REMOTE_PATH --repo $REPO

# Step 6: set required secrets for API deploy
Write-Host "`nStep 6: Setting API deploy secrets..." -ForegroundColor Cyan
& $ghExe secret set CPANEL_API_SFTP_HOST --repo $REPO
& $ghExe secret set CPANEL_API_SFTP_PORT --repo $REPO
& $ghExe secret set CPANEL_API_SFTP_USERNAME --repo $REPO
& $ghExe secret set CPANEL_API_SFTP_PASSWORD --repo $REPO
& $ghExe secret set CPANEL_API_SFTP_REMOTE_PATH --repo $REPO

# Step 7: set required secrets for rider deploy
Write-Host "`nStep 7: Setting rider deploy secrets..." -ForegroundColor Cyan
& $ghExe secret set CPANEL_RIDER_SFTP_HOST --repo $REPO
& $ghExe secret set CPANEL_RIDER_SFTP_PORT --repo $REPO
& $ghExe secret set CPANEL_RIDER_SFTP_USERNAME --repo $REPO
& $ghExe secret set CPANEL_RIDER_SFTP_PASSWORD --repo $REPO
& $ghExe secret set CPANEL_RIDER_SFTP_REMOTE_PATH --repo $REPO

# Step 8: set required secrets for driver deploy
Write-Host "`nStep 8: Setting driver deploy secrets..." -ForegroundColor Cyan
& $ghExe secret set CPANEL_DRIVER_SFTP_HOST --repo $REPO
& $ghExe secret set CPANEL_DRIVER_SFTP_PORT --repo $REPO
& $ghExe secret set CPANEL_DRIVER_SFTP_USERNAME --repo $REPO
& $ghExe secret set CPANEL_DRIVER_SFTP_PASSWORD --repo $REPO
& $ghExe secret set CPANEL_DRIVER_SFTP_REMOTE_PATH --repo $REPO

# Step 9: trigger deploy workflows
Write-Host "`nStep 9: Triggering deploy workflows..." -ForegroundColor Cyan
& $ghExe workflow run "Deploy to GoDaddy cPanel (SFTP)" --repo $REPO
& $ghExe workflow run "Deploy API to GoDaddy cPanel (SFTP)" --repo $REPO
& $ghExe workflow run "Deploy Rider and Driver UIs to GoDaddy cPanel (SFTP)" --repo $REPO

# Step 10: watch latest runs
Write-Host "`nStep 10: Recent workflow runs..." -ForegroundColor Cyan
& $ghExe run list --repo $REPO --limit 10

Write-Host "`nDone. Check the URLs above for workflow status." -ForegroundColor Green
